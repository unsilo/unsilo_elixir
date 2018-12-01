defmodule Unsilo.Factory do
  use ExMachina.Ecto, repo: Unsilo.Repo

  alias Unsilo.Accounts.User
  alias Unsilo.Domains.Spot
  alias Unsilo.Domains.Subscriber

  def user_factory do
    %User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_hash: sequence(:password_hash, &"password_hash-#{&1}@password_hash")
    }
  end

  def spot_factory do
    %Spot{
      name: "just a name",
      domains: [sequence(:domain, &"site-#{&1}@example.com")],
      user_id: build(:user).id
    }
  end

  def subscriber_factory do
    %Subscriber{
      email: sequence(:email, &"email-#{&1}@example.com"),
      spot_id: build(:spot).id
    }
  end
end
