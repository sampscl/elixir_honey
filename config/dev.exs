import Config
das_app = :elixir_honey
console_log_format = "$time [$level] $levelpad$message\n"

# Logger configuration
config :logger,
console: [
    level: :debug,
    format: console_log_format
  ],
  handle_sasl_reports: false,
  handle_otp_reports: true

# Log file backends
config :logger,
backends: [
  :console,
]

# log limits
config :logger,
  truncate: :infinity
