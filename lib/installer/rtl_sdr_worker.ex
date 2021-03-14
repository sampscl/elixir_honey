defmodule Installer.RtlSdr.Worker do
  @moduledoc """
  The rtl-sdr discovery worker
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
    {:ok, do_detect(~M{%State})}
  end

  ##############################
  # Internal Calls
  ##############################

  def do_detect(state) do
    case System.cmd("lsusb", ["-d", "OBDA:2838"]) do
      {result, 0} ->
        # result is a string with 1 line per RTL-SDR
        _ =
          result
          |> String.graphemes()
          |> Enum.reduce(0, fn
            ("\n", ndx) ->
              LoggerUtils.info("Defining rtl-sdr index #{ndx}")
              Config.Manager.define_radio("rtl-sdr_#{ndx + 1}", "rtl-sdr", ndx)
              ndx + 1

            (_, ndx) ->
              ndx
          end)
      err ->
        LoggerUtils.error("Failed to run lsusb, error #{inspect(err, pretty: true)}")
    end
    state
  end
end
