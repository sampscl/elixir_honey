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
    children = case is_installer_mode() do
      false ->
        LoggerUtils.info("Systems are configured, not entering installer mode")
        []

      true ->
        # No systems, lets get to configuring some
        LoggerUtils.info("No systems are configured, entering installer mode")
        [
          {Installer.SystemBuilder.Manager, :ok},
          {Installer.RtlSdr.Worker, :ok},
          {Installer.Honeywell345.Worker, :ok},
        ]
    end
    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Check if installer mode
  ## Returns
  - true
  - false
  """
  def is_installer_mode do
    case Config.Manager.get_systems() do
      {:ok, _systems} -> false
      {:error, _reason} -> true
    end
  end
end
