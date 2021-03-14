defmodule Installer.Sup do
  @moduledoc """
  Supervisor for installers.
  """
  use Supervisor
  use LoggerUtils

  def start_link(:ok), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl Supervisor
  def init(:ok) do
    LoggerUtils.info("Starting")
    children = case Config.Manager.get_systems() do
      {:ok, _systems} ->
        LoggerUtils.info("Systems are configured, not entering installer mode")
        []

      {:error, _reason} ->
        # No systems, lets get to configuring some
        LoggerUtils.info("No systems are configured, entering installer mode")
        [
          {Installer.RtlSdr.Worker, :ok},
          {Installer.Honeywell345.Worker, :ok},
        ]
    end
    Supervisor.init(children, strategy: :one_for_one)
  end
end
