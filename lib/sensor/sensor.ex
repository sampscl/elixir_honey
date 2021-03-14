defmodule Sensor do
  @moduledoc """
  API module for Sensors
  """

  @doc """
  Start the named sensor

  ## Parameters
  - sensor The sensor type, e.g. `:honeywell_345`

  ## Returns
  - see `Supervisor::on_start_child`, typically {:ok, pid}
  """
  def start_sensor(sensor)
  def start_sensor(:honeywell_345) do
  end

end
