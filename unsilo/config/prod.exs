use Mix.Config

config :unsilo, UnsiloWeb.Endpoint,
  http: [port: 4011],
  url: [host: "sfuchs.fyi", scheme: "https", port: 443],
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :debug

import_config "prod.secret.exs"
