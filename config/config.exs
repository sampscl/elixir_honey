# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#

das_app = :elixir_honey
base_log_dir = "/var/log/#{Atom.to_string(das_app)}"
console_log_format = "$time [$level] $levelpad$message\n"
disk_log_format = "$date $time [$level] $levelpad$message\n"

config das_app, base_log_dir: base_log_dir
config das_app, console_log_format: console_log_format
config das_app, disk_log_format: disk_log_format

# configure the logs
# Common configs for umbrella.

# Log file backends
config :logger,
  backends: [
    :console,
    {LoggerFileBackend, :debug_log},
    {LoggerFileBackend, :console_log},
    {LoggerFileBackend, :error_log},
  ]

config :logger, :console_log,
  path: "#{base_log_dir}/console.log",
  format: console_log_format,
  level: :info

config :logger, :error_log,
  path: "#{base_log_dir}/error.log",
  format: disk_log_format,
  level: :error

config :logger, :debug_log,
  path: "#{base_log_dir}/debug.log",
  format: disk_log_format,
  level: :debug

import_config "#{config_env()}.exs"
