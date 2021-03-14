defmodule Installer.Honeywell345.Worker do
  @moduledoc """
  The Honeywell 345 sensor uses the rtl 433 project as a subprocess to
  capture wireless sensor messages.
  """

  import ShorterMaps
  use GenServer
  use LoggerUtils

  ##############################
  # API
  ##############################
  def start_link(:ok), do: GenServer.start_link(__MODULE__, :ok)

  defmodule State do
    @moduledoc false
    defstruct [
    ]
  end

  ##############################
  # GenServer Callbacks
  ##############################

  @impl GenServer
  def init(:ok) do
    LoggerUtils.info("Starting")
    {:ok, ~M{%State}}
  end

  ##############################
  # Internal Calls
  ##############################
end
