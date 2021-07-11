defmodule PubSub do
  @moduledoc """
  PubSub module contains modules and functions related to pub/sub. Duh.
  """

  use Flub.Helpers

  # Notifications about new sensors, source is a radio source, type is in ["honeywell_345"]
  # define_channel("sensor_discovery", source: nil, type: nil)

  # Zone discovered during install mode scan, radio is a Config.Manager.Radio.t
  # and id is an identifier for the zone
  define_channel("zone_discovery", radio: nil, id: 0)

  # Radio discovered by install mode, radio is a Config.Manager.Radio.t
  define_channel("radio_discovery", radio: nil)

  # A system has been configured, system is a %Config.Manager.System{}
  define_channel("system_configured", system: nil)

  # A system has been deleted, system_name is a string name of the system
  define_channel("system_deleted", system_name: nil)

end
