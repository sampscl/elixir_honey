defmodule Web.Sup  do
  @moduledoc """
  Supervise web subsystem
  """
  use Supervisor
  use LoggerUtils
  import ShorterMaps

  def start_link(:ok), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl Supervisor
  def init(:ok) do
    LoggerUtils.info("Starting")
    children() |> Supervisor.init(strategy: :one_for_one)
  end

  def dispatch do
    [{:_,
      [
        # special handling in dispatch for the websocket,
        # since there isn't a plug for ws.
        {"/ws", Web.Handlers.Websocket, ~M{%Web.Handlers.Websocket.State}},
        {:_, Plug.Cowboy.Handler, {Web.AppRouter, []}}
      ]
    }]
  end

  def children do
    api_port = 8080
    [
      {Plug.Cowboy, scheme: :http, plug: Web.AppRouter, options: [
        port: api_port,
        otp_app: :elixir_honey,
        dispatch: dispatch(),
      ]},
      {Web.Websocket.Worker, :ok},
    ]
  end
end
