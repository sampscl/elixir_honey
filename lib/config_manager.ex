defmodule Config.Manager do
  @moduledoc """
  Genserver for managing the system configuration. Must be started first!
  """
  use GenServer
  use LoggerUtils
  use PatternTap
  import ShorterMaps

  ##############################
  # API
  ##############################

  def start_link(:ok) , do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc """
  Reload the config
  """
  def reload, do: GenServer.call(__MODULE__, :reload)

  @doc """
  Get the list of configured systems
  ## Returns
  - {:ok, systems} where systems is a list of (string keyed) systems from the config file
  - {:error, reason} Failed for reason
  """
  def get_systems, do: GenServer.call(__MODULE__, :get_systems)

  @doc """
  Define a radio in the configuration; {type, index} form a unique pair
  ## Params
  - name: String The radio name, can be nil if unknown
  - type: String The radio type
  - index: Integer The index of this radio if there are multiples of the same type available
  ## Return
  - :ok All is well, the radio was defined or updated
  - {:error, reason} Failed for some reason
  """
  def define_radio(name, type, index), do: GenServer.call(__MODULE__, {:define_radio, name, type, index})

  defmodule Radio do
    @moduledoc "How a radio is defined"
    defstruct [
      name: nil,
      type: nil,
      index: nil,
    ]
  end

  defmodule State do
    @moduledoc false
    defstruct [
      cfg: nil, # The configuration as loaded or overridden
      radios: %{}, # k: {type, index}, v: %Radio{}
    ]
  end

  ##############################
  # GenServer Callbacks
  ##############################

  @impl GenServer
  def init(:ok) do
    LoggerUtils.info("Starting")

    cfg = read_example_config()
    LoggerUtils.debug("cfg => #{inspect(cfg, pretty: true, limit: :infinity)}")

    {:ok, parse_config(~M{%State cfg})}
  end

  @impl GenServer
  def handle_call(:reload, _from, state) do
    {:reply, :ok, ~M{state| cfg: read_example_config()}}
  end

  @impl GenServer
  def handle_call(:get_systems, _from, state) do
    {new_state, response} = do_get_systems(state)
    {:reply, response, new_state}
  end

  @impl GenServer
  def handle_call({:define_radio, name, type, index}, _from, state) do
    {new_state, response} = do_define_radio(state, name, type, index)
    {:reply, response, new_state}
  end

  ##############################
  # Internal Calls
  ##############################

  def read_example_config do
    result = :elixir_honey
      |> :code.priv_dir()
      |> Path.join("samples")
      |> Path.join("config.yml")
      |> YamlElixir.read_from_file()

    case result do
      {:ok, cfg} ->
        cfg

      {:error, reason} ->
        LoggerUtils.error("Failed to parse config: #{inspect(reason, pretty: true, limit: :infinity)}")
        nil
    end
  end

  def do_get_systems(~M{cfg: nil} = state), do: {state, {:error, "no config"}}
  def do_get_systems(~M{cfg} = state) do
    case get_in(cfg, ["systems"]) do
      nil ->
        {state, {:ok, []}}

      systems when is_list(systems) ->
        {state, {:ok, systems}}

      _ ->
        {state, {:error, "malformed systems configuration"}}
    end
  end

  def do_define_radio(~M{radios} = state, name, type, index) when is_number(index) and type in ["rtl-sdr"] do
    key = {type, index}
    radio = Map.get(radios, key, ~M{%Radio name: nil})
    case {radio.name, name} do
      {nil, nil} ->
        # no new data
        {state, :ok}

      {_old_name, nil} ->
        # no new data
        {state, :ok}

      {_, new_name} ->
        # update name
        {~M{state| radios: Map.put(radios, key, ~M/radio| name: new_name, type, index/)}, :ok}
    end
  end
  def do_define_radio(state, _name, _type, _index), do: {state, {:error, "invalid index or type"}}

  def parse_config(~M{cfg: nil} = state), do: state
  def parse_config(~M{cfg} = state) do

    # cfg is string-keyed from the original yaml
    cfg
    |> Map.get("systems")
    |> Enum.reduce(state, fn(system, systems_state) ->
      system
      |> Map.get("sensors")
      |> Enum.reduce(systems_state, fn(sensor, sensors_state) ->
        ~m{name, type, index} = _radio = sensor["source"]
        {updated_sensors_state, _} = do_define_radio(sensors_state, name, type, index)
        updated_sensors_state
      end)
    end)

  end
end
