defmodule Unsilo.Domains do
  @moduledoc """
  The Domains context.
  """

  import Ecto.Query, warn: false
  alias Unsilo.Repo

  alias Unsilo.Domains.Spot
  alias Unsilo.Domains.Subscriber

  def list_spots_for_user(user) do
    Spot.for_user(user)
  end

  def spot_for_domain(domain) do
    Spot.for_domain(domain)
  end
  
  def increment_spot_count(spot) do
    Spot
    |> where(id: ^spot.id)
    |> Repo.update_all(inc: [count: 1])
  end

  def get_spot!(id) do
    Repo.get!(Spot, id)
      |> Repo.preload([:subscribers])
  end

  def create_spot(attrs \\ %{}) do
    %Spot{}
    |> Spot.changeset(attrs)
    |> Repo.insert()
  end

  def update_spot(%Spot{} = spot, attrs) do
    spot
    |> Spot.changeset(attrs)
    |> Repo.update()
  end

  def delete_spot(%Spot{} = spot) do
    Repo.delete(spot)
  end

  def change_spot(%Spot{} = spot) do
    Spot.changeset(spot, %{})
  end

  alias Unsilo.Domains.Subscriber

  def list_subscriber do
    Repo.all(Subscriber)
  end

  def get_subscriber!(id), do: Repo.get!(Subscriber, id)

  def get_subscriber(id), do: Repo.get(Subscriber, id)

  def create_subscriber(attrs \\ %{}) do
    %Subscriber{}
    |> Subscriber.changeset(attrs)
    |> Repo.insert()
  end

  def update_subscriber(%Subscriber{} = subscriber, attrs) do
    subscriber
    |> Subscriber.changeset(attrs)
    |> Repo.update()
  end

  def delete_subscriber(%Subscriber{} = subscriber) do
    Repo.delete(subscriber)
  end

  def change_subscriber(%Subscriber{} = subscriber) do
    Subscriber.changeset(subscriber, %{})
  end
end
