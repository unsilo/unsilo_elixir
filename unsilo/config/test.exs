use Mix.Config

config :unsilo, UnsiloWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn

config :unsilo, Unsilo.Repo,
  username: "postgres",
  password: "postgres",
  database: "unsilo_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :bcrypt_elixir, :log_rounds, 4
