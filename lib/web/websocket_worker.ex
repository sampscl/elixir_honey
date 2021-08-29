# :ok
# Web.Websocket.Worker

defmodule Web.Websocket.Worker do
  @moduledoc """
  Manage pub sub publishing to websockets
  """
  use GenServer
  use QolUp.LoggerUtils
  import ShorterMaps

  ##############################
  # API
  ##############################

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, [:ok], name: __MODULE__)
  end

  defmodule State do
    @moduledoc false
    defstruct []
  end

  ##############################
  # GenServer Callbacks
  ##############################

  def init([:ok]) do
    QolUp.LoggerUtils.info("starting")
    PubSub.sub_radio_discovery()
    PubSub.sub_zone_discovery()
    {:ok, %State{}}
  end

  def handle_info(~M{%Flub.Message data, channel}, state) do
    QolUp.LoggerUtils.debug(inspect(~M{channel, data}, pretty: true))
    Web.Handlers.Websocket.send_msg_to_all(channel, data)
    {:noreply, state}
  end

  ##############################
  # Internal Calls
  ##############################
end
