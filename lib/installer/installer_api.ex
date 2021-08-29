defmodule Installer.Api do
  @moduledoc """
  API functions for the installer system.
  """

  @doc """
  Redetect radios of a given type
  ## Parameters
  - type The radio type string, see [the example](priv/samples/config.yml) for examples
  """
  def redetect(type \\ "all")
  def redetect("all"), do: Installer.RtlSdr.Worker.redetect()
  def redetect("rtl-sdr"), do: Installer.RtlSdr.Worker.redetect()

  @doc """
  Start scanning with a radio. Will scan forever until stop_scan is called with that. Each
  zone detected during the scan will be published to the zone_discovery channel, see `PubSub`.
  The underlying worker will only support 1 scan at a type; you cannot start simultaneous scans of the
  same system_type on different radios.
  ## Parameters
  - system_type: The system type string, see [the example](priv/samples/config.yml) for examples
  - radio: A Config.Manager.Radio.t, the radio to scan with
  ## Returns
  - :ok All is well, scanning is in progress
  - {:error, reason} Failed for reason
  """
  def start_scan(system_type, radio)
  def start_scan("honeywell_345" = _system_type, radio), do: Installer.Honeywell345.Worker.radio_scan(radio)

  @doc """
  Stop scanning for a system type.
  ## Parameters
  - system_type: The system type string, see [the example](priv/samples/config.yml) for examples
  ## Returns
  - :ok All is well, scanning is in progress
  - {:error, reason} Failed for reason
  """
  def stop_scan(system_type)
  def stop_scan("honeywell_345" = _system_type), do: Installer.Honeywell345.Worker.stop_scan()
end
