defmodule Fw.Application do
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children("host") do
    [
      # Starts a worker by calling: Fw.Worker.start_link(arg)
      # {Fw.Worker, arg},
    ]
  end

  def children(_target) do
    [
#      {MuonTrap.Daemon, ["/usr/bin/postgres/bin", ["arg1", "arg2"], options]}
    ]
  end
end
