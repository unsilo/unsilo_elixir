defmodule Unsilo.Repo do
  use Ecto.Repo,
    otp_app: :unsilo,
    adapter: Ecto.Adapters.Postgres
end
