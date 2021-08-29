defmodule Web.Handlers.Websocket do
  @moduledoc """
  Websocket.
  """
  @behaviour :cowboy_websocket
  use QolUp.LoggerUtils
  import ShorterMaps

  ##############################
  # API
  ##############################

  def send_msg_to_all(type, body) do
    # QolUp.LoggerUtils.debug("#{inspect(~M/type, body/, pretty: true)}")

    pkg = ~M{type, body}
    for pid <- :pg.get_members(__MODULE__), do: send(pid, {:to_client, pkg})
  end

  defmodule State do
    @moduledoc false
    defstruct [
      # Timer ref from Process.send_after()
      timer_ref: nil
    ]

    @type t :: %__MODULE__{}
  end

  ##############################
  # Websocket Callbacks
  ##############################

  @impl :cowboy_websocket
  def init(req, _state) do
    {ip, _port} = :cowboy_req.peer(req)
    QolUp.LoggerUtils.info("WS open request for #{inspect(ip)}")
    {:cowboy_websocket, req, %State{}}
  end

  @impl :cowboy_websocket
  def websocket_init(state) do
    QolUp.LoggerUtils.info("Websocket_init")
    :pg.join(__MODULE__, self())
    {:ok, ~M{state| timer_ref: Process.send_after(self(), :send_ping, 10_000)}}
  end

  @impl :cowboy_websocket
  def websocket_handle(:ping, state), do: {:ok, state}

  @impl :cowboy_websocket
  def websocket_handle(:pong, state), do: {:ok, state}

  @impl :cowboy_websocket
  def websocket_handle(_frame, state) do
    # QolUp.LoggerUtils.debug("#{inspect(frame, pretty: true)}")
    {:ok, state}
  end

  @impl :cowboy_websocket
  def websocket_info({:to_client, pkg}, state) do
    # QolUp.LoggerUtils.debug("#{inspect(pkg, pretty: true)}")
    {:reply, {:text, Utils.Json.encode!(pkg)}, state}
  end

  @impl :cowboy_websocket
  def websocket_info(:send_ping, state) do
    {:reply, :ping, ~M{state| timer_ref: Process.send_after(self(), :send_ping, 10_000)}}
  end

  @impl :cowboy_websocket
  def terminate(reason, _req, _state) do
    QolUp.LoggerUtils.warn("terminating websocket because #{inspect(reason)}")
    :ok
  end

  ##############################
  # Internal Calls
  ##############################
end
