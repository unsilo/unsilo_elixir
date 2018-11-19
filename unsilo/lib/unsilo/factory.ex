defmodule Unsilo.Factory do
  use ExMachina.Ecto, repo: Unsilo.Repo

  alias Unsilo.Accounts.User

  def user_factory do
    %User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
    }
  end
end
