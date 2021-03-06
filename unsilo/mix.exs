defmodule Unsilo.MixProject do
  use Mix.Project

  def project do
    [
      app: :unsilo,
      version: "3.0.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Unsilo.Application, []},
      extra_applications: [:logger, :runtime_tools, :canada]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.4.1"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:arc, "~> 0.11.0"},
      {:arc_ecto, "~> 0.11.1"},
      {:ecto_enum, "~> 1.1"},
      {:guardian, "~> 1.0"},
      {:distillery, "~> 2.0"},
      {:feeder_ex, "~> 1.1"},
      {:edeliver, ">= 1.6.0"},
      {:html_sanitize_ex, "~> 1.3.0"},
      {:canary, "~> 1.1.1"},
      {:calliope, "0.4.1"},
      {:pdf_generator, ">=0.4.0"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:comeonin, "~> 4.0"},
      {:cors_plug, "~> 1.5"},
      {:httpoison, "~> 1.5"},
      {:bcrypt_elixir, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:timex, "~> 3.1"},
      {:ex_machina, "~> 2.2"},
      {:phoenix_haml, "~> 0.2.3"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:excoveralls, "~> 0.10", only: :test},
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
