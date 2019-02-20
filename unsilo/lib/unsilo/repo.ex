defmodule Unsilo.Repo do
  use Ecto.Repo,
    otp_app: :unsilo,
    adapter: Sqlite.Ecto2
end
