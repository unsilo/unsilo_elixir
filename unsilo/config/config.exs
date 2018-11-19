use Mix.Config

config :unsilo,
  ecto_repos: [Unsilo.Repo],
  app_domain: "sfuchs.fyi"

config :phoenix, :template_engines,
  haml: PhoenixHaml.Engine

config :unsilo, UnsiloWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "oSxFxllzYHVBGyJy3s9QQ4cryjLNmYQA2LzHmUf1cMNZM1MIX1jEb6OyVtlZku4g",
  render_errors: [view: UnsiloWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Unsilo.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :unsilo, UnsiloWeb.Auth.Guardian,
       issuer: "unsilo",
       secret_key: "uDTx1Z2rkpSdKLgKpMtJqnmGOA2l6TJNUxMA72UgL6NS2Nn1Hb7R0XFeLCrTcwtp"

import_config "#{Mix.env()}.exs"
