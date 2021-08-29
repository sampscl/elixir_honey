defmodule Sensor.Honeywell345.Worker do
  @moduledoc """
  The Honeywell 345 sensor uses the rtl 433 project as a subprocess to
  capture wireless sensor messages.
  """

  import ShorterMaps
  use GenServer
  use QolUp.LoggerUtils

  ##############################
  # API
  ##############################
  def start_link({system_name, sensor}),
    do: GenServer.start_link(__MODULE__, {system_name, sensor})

  defmodule State do
    @moduledoc false
    defstruct [
      # system name
      system_name: nil,
      # sensor
      sensor: nil
    ]
  end

  ##############################
  # GenServer Callbacks
  ##############################

  @impl GenServer
  def init({system_name, sensor}) do
    QolUp.LoggerUtils.info("Starting #{inspect(~M{system_name, sensor}, pretty: true)}")
    # command line "rtl_433 -f 344940000 -F json -R 70"
    # The "-R 70" can *vary* from version to version of the rtl_433 program!
    {:ok, ~M{%State system_name, sensor}}
  end

  ##############################
  # Internal Calls
  ##############################
end
