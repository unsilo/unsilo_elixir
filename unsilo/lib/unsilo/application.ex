defmodule Unsilo.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Unsilo.Repo,
      Unsilo.InfluxConnection,
      UnsiloWeb.Endpoint,
      Unsilo.Feeds.Heartbeat
    ]

    opts = [strategy: :one_for_one, name: Unsilo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    UnsiloWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
