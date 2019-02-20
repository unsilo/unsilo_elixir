use Mix.Config

config :unsilo, UnsiloWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [yarn: ["run", "watch", cd: Path.expand("../assets", __DIR__)]]

config :unsilo, UnsiloWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/unsilo_web/views/.*(ex)$},
      ~r{lib/unsilo_web/templates/.*(eex|haml)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :unsilo, Unsilo.Repo,
  adapter: Sqlite.Ecto2,
  database: "unsilo_dev.sqlite3",
  password: "postgres",
  database: "unsilo_dev",
  migration_source: "some_other_table_for_schema_migrations",
  pool_size: 10
