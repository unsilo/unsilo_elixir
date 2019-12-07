use Mix.Config

config :unsilo, UnsiloWeb.Endpoint,
  http: [port: 4080],
  url: [host: "unsilo.local", scheme: "http", port: 4080],
  server: true,
  check_origin: ["//unsilo.local", "//10.0.1.212"],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :debug

config :unsilo, Unsilo.UserController, allow_signups: false

import_config "prod.secret.exs"
