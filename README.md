# ElixirHoney

Honey house, elixir style!

SDR-based wireless sensor monitoring, RabbitMQ bussing,
touchscreen monitoring and control, and so much more!

## Configuration

Honey uses YAML for configuration. See [the example](priv/samples/config.yml) for an example.

## Notes

rtl_433 example output from honeywell `rtl_433 -f 344940000 -F json -R 70`:
```json
{"time" : "2021-03-20 11:47:16", "model" : "Honeywell-Security", "id" : 125008, "channel" : 8, "event" : 52, "state" : "closed", "contact_open" : 0, "reed_open" : 1, "alarm" : 1, "tamper" : 0, "battery_ok" : 1, "heartbeat" : 1}
```