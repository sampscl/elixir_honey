defmodule Installer.Honeywell345.Worker do
  @moduledoc """
  The Honeywell 345 sensor uses the rtl 433 project as a subprocess to
  capture wireless sensor messages.
  """

  import ShorterMaps
  use GenServer
  use LoggerUtils

  ##############################
  # API
  ##############################
  def start_link(:ok), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc """
  Start a radio scan
  ## Parameters
  - radio Config.Manager.Radio.t The radio
  ## Returns
  - :ok All is well, scan started
  - {:error, reason} Failed for reason
  """
  def radio_scan(radio), do: GenServer.call(__MODULE__, {:radio_scan, radio})

  @doc """
  Stop a radio scan
  """
  def stop_scan, do: GenServer.call(__MODULE__, :stop_scan)

  defmodule State do
    @moduledoc false
    defstruct [
      radio: nil, # Config.Manager.Radio.t that is currently being used to scan
      pid: nil, # pid of subprocess
      stdin_lb: LineBuffer.new(), # line buffer for stdin
    ]
  end

  ##############################
  # GenServer Callbacks
  ##############################

  @impl GenServer
  def init(:ok) do
    LoggerUtils.info("Starting")
    {:ok, ~M{%State}}
  end

  @impl GenServer
  def handle_call({:radio_scan, radio}, _from, state) do
    {updated_state, result} = do_radio_scan(state, radio)
    {:reply, result, updated_state}
  end

  @impl GenServer
  def handle_call(:stop_scan, _from, state) do
    {updated_state, result} = do_stop_scan(state)
    {:reply, result, updated_state}
  end

  @impl GenServer
  def handle_info({_pid, :data, :out, data}, state) do
    {:noreply, do_handle_data(state, :out, data)}
  end

  @impl GenServer
  def handle_info({_pid, :data, :err, data}, state) do
    {:noreply, do_handle_data(state, :err, data)}
  end

  @impl GenServer
  def handle_info({dead_pid, :result, result}, ~M{pid} = state) do
    LoggerUtils.info("Pid #{inspect(dead_pid)} exited: #{inspect(result, pretty: true)}")
    if dead_pid == pid do
      # pid we're tracking pid died, nil it out
      {:noreply, ~M{state| pid: nil}}
    else
      # may already have a new pid
      {:noreply, state}
    end
  end

  ##############################
  # Internal Calls
  ##############################

  def do_radio_scan(~M{pid: nil} = state, radio) do
    {:ok, pid} = Executus.execute("rtl_433 -d #{radio.index} -f 344940000 -F json -R 70", sync: false)
    stdin_lb = LineBuffer.new()
    {~M{state| pid, stdin_lb, radio}, :ok}
  end
  def do_radio_scan(state, _radio), do: {state, {:error, "scan in progress"}}

  def do_stop_scan(~M{pid: nil} = state), do: {state, :ok}
  def do_stop_scan(~M{pid} = state) do
    Executus.signal(pid, :INT)
    {~M{state| pid: nil}, :ok}
  end

  def do_handle_data(~M{stdin_lb} = state, :out, data) do
    LoggerUtils.debug("rtl_433 reports: #{inspect(data, pretty: true)}")
    {updated_stdin_lb, lines} = LineBuffer.add_data(stdin_lb, data)
    process_lines(~M{state| stdin_lb: updated_stdin_lb}, lines)
  end

  def do_handle_data(state, :err, data) do
    LoggerUtils.debug("rtl_433 is whining: #{inspect(data, pretty: true)}")
    state
  end

  def process_lines(state, []), do: state
  def process_lines(~M{radio} = state, [line| rest]) do
    id =
      line
      |> Utils.Json.decode!()
      |> Map.get("id")

    LoggerUtils.info("zone discovery: #{inspect(~M{id, radio}, pretty: true)}")

    PubSub.pub_zone_discovery(~M{%PubSub.ZoneDiscovery radio, id})

    process_lines(state, rest)
  end
end
