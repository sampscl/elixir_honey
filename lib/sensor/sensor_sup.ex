defmodule Sensor.Sup do
  @moduledoc """
  Supervisor for sensors. At runtime, will determine which
  worker children are needed and start them.
  """

  import ShorterMaps
  use Supervisor
  use LoggerUtils

  def start_link(:ok), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl Supervisor
  def init(:ok) do
    LoggerUtils.info("Starting")
    children = configured_children()
    Supervisor.init(children, strategy: :one_for_one)
  end

  def configured_children do
    case Config.Manager.get_systems() do
      {:ok, systems} ->
        Enum.reduce(systems, [], fn(~m{name, sensors} = _system, child_list) ->
          Enum.reduce(sensors, child_list, fn(sensor, sensor_child_list) ->
            [sensor_child_spec(name, sensor)| sensor_child_list]
          end)
        end)

      {:error, reason} ->
        LoggerUtils.error("No systems configured, error: #{inspect(reason)}")
        []
    end
  end

  def sensor_child_spec(system_name, ~m{type} = sensor) do
    case type do
      "honeywell_345" -> {Sensor.Honeywell345.Worker, {system_name, sensor}}
    end
  end

end
