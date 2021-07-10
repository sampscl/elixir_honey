defmodule ElixirHoney.Application do
  @moduledoc """
  Application entry point
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # pg_spec(), # flub also starts this
      {Config.Manager, :ok},
      {Sensor.Sup, :ok},
      {Installer.Sup, :ok},
      {Web.Sup, :ok}, # web should generally be last after everything else initializes
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  defp pg_spec do
    %{
      id: :pg,
      start: {:pg, :start_link, []}
    }
  end
end
