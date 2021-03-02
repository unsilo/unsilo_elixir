use Mix.Config

config :unsilo,
  ecto_repos: [Unsilo.Repo],
  app_domain: "sfuchs.fyi"

config :unsilo, UnsiloWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "oSxFxllzYHVBGyJy3s9QQ4cryjLNmYQA2LzHmUf1cMNZM1MIX1jEb6OyVtlZku4g",
  render_errors: [view: UnsiloWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Unsilo.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "8CO/vMlHX7M1G6OKyQXgAVCKJ/7AhBf0"
  ]

config :unsilo, UnsiloWeb.InfluxConnection,
  database: "unsilo_influx_database",
  host: "localhost",
  http_opts: [insecure: true, proxy: "http://company.proxy"],
  pool: [max_overflow: 10, size: 50],
  port: 8086,
  scheme: "http",
  writer: Instream.Writer.Line

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :rain_machine, RainMachine.Device, use_mock_data: false

config :canary,
  repo: Unsilo.Repo

config :unsilo, Unsilo.UserController, allow_signups: true

config :unsilo, Unsilo.Feeds.Heartbeat, delete_retention: 3

config :arc,
  storage: Arc.Storage.Local

config :phoenix, :json_library, Jason

config :phoenix, :template_engines,
  leex: Phoenix.LiveView.Engine,
  haml: PhoenixHaml.Engine

config :unsilo, UnsiloWeb.Auth.Guardian,
  issuer: "unsilo",
  secret_key: "uDTx1Z2rkpSdKLgKpMtJqnmGOA2l6TJNUxMA72UgL6NS2Nn1Hb7R0XFeLCrTcwtp"

import_config "#{Mix.env()}.exs"

if Mix.target() != :host do
  import_config "target.exs"
else
  import_config "host.exs"
end
