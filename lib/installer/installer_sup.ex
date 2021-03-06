defmodule Installer.Sup do
  @moduledoc """
  Supervisor for installers.
  """
  use Supervisor
  use QolUp.LoggerUtils

  def start_link(:ok), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl Supervisor
  def init(:ok) do
    QolUp.LoggerUtils.info("Starting")

    children =
      case installer_mode?() do
        false ->
          QolUp.LoggerUtils.info("Systems are configured, not entering installer mode")
          []

        true ->
          # No systems, lets get to configuring some
          QolUp.LoggerUtils.info("No systems are configured, entering installer mode")

          [
            {Installer.SystemBuilder.Manager, :ok},
            {Installer.RtlSdr.Worker, :ok},
            {Installer.Honeywell345.Worker, :ok}
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
  def installer_mode? do
    {:ok, systems} = Config.Manager.get_systems()
    systems == %{}
  end
end
