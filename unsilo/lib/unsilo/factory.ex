defmodule Unsilo.Factory do
  use ExMachina.Ecto, repo: Unsilo.Repo

  alias Unsilo.Accounts.User
  alias Unsilo.Domains.Spot
  alias Unsilo.Domains.Subscriber

  alias Unsilo.Feeds.River
  alias Unsilo.Feeds.Feed
  alias Unsilo.Feeds.Story

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

  def river_factory do
    %River{
      name: sequence(:river_name, &"river-#{&1}"),
      user_id: build(:user).id
    }
  end

  def feed_factory do
    %Feed{
      name: sequence(:feed_name, &"feed-#{&1}"),
      url: sequence(:feed_url, &"http://feed-#{&1}.com"),
      user_id: build(:user).id,
      river_id: build(:river).id
    }
  end

  def story_factory do
    %Story{
      title: sequence(:story_name, &"story-#{&1}"),
      url: sequence(:story_url, &"http://story-#{&1}.com"),
      user_id: build(:user).id,
      feed_id: build(:feed).id
    }
  end
end
