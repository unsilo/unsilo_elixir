defmodule Unsilo.DomainsTest do
  use Unsilo.DataCase

  alias Unsilo.Domains
  import Unsilo.Factory

  describe "spots" do
    alias Unsilo.Domains.Spot

    @valid_attrs %{
      description: "some description",
      domains: "some domain",
      name: "some name",
      tagline: "some tagline",
      user_id: 42
    }

    @update_attrs %{
      description: "some updated description",
      domains: "some updated domain",
      name: "some updated name",
      tagline: "some updated tagline",
      user_id: 43
    }
    @invalid_attrs %{description: nil, domain: nil, name: nil, tagline: nil, user_id: nil}

    setup do
      user = insert(:user)
      another_user = insert(:user)

      conn =
        Phoenix.ConnTest.build_conn()
        |> UnsiloWeb.Auth.Guardian.Plug.sign_in(user)

      {:ok, conn: conn, user: user, another_user: another_user}
    end

    def spot_fixture(attrs \\ %{}) do
      {:ok, spot} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Domains.create_spot()

      spot |> Repo.preload([:subscribers])
    end

    test "list_spots/0 returns all spots", %{user: user, another_user: another_user} do
      spot = spot_fixture(user_id: user.id)
      _not_spot = spot_fixture(user_id: another_user.id)
      assert Domains.list_spots_for_user(user) == [spot]
    end

    test "get_spot!/1 returns the spot with given id" do
      spot = spot_fixture()
      assert Domains.get_spot!(spot.id) == spot
    end

    test "create_spot/1 with valid data creates a spot" do
      assert {:ok, %Spot{} = spot} = Domains.create_spot(@valid_attrs)
      assert spot.description == "some description"
      assert spot.domains == ["some domain"]
      assert spot.name == "some name"
      assert spot.tagline == "some tagline"
      assert spot.user_id == 42
    end

    test "create_spot/1 can create multiple domains" do
      assert {:ok, %Spot{} = spot} =
               Domains.create_spot(%{@valid_attrs | domains: "dom1\r\ndom2"})

      assert spot.description == "some description"
      assert spot.domains == ["dom1", "dom2"]
      assert spot.name == "some name"
      assert spot.tagline == "some tagline"
      assert spot.user_id == 42
    end

    test "create_spot/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Domains.create_spot(@invalid_attrs)
    end

    test "update_spot/2 with valid data updates the spot" do
      spot = spot_fixture()
      assert {:ok, %Spot{} = spot} = Domains.update_spot(spot, @update_attrs)
      assert spot.description == "some updated description"
      assert spot.domains == ["some updated domain"]
      assert spot.name == "some updated name"
      assert spot.tagline == "some updated tagline"
      assert spot.user_id == 43
    end

    test "update_spot/2 with invalid data returns error changeset" do
      spot = spot_fixture()
      assert {:error, %Ecto.Changeset{}} = Domains.update_spot(spot, @invalid_attrs)
      assert spot == Domains.get_spot!(spot.id)
    end

    test "delete_spot/1 deletes the spot" do
      spot = spot_fixture()
      assert {:ok, %Spot{}} = Domains.delete_spot(spot)
      assert_raise Ecto.NoResultsError, fn -> Domains.get_spot!(spot.id) end
    end

    test "change_spot/1 returns a spot changeset" do
      spot = spot_fixture()
      assert %Ecto.Changeset{} = Domains.change_spot(spot)
    end
  end

  describe "subscriber" do
    alias Unsilo.Domains.Subscriber

    @valid_attrs %{email: "some email", spot_id: 42}
    @update_attrs %{email: "some updated email", spot_id: 43}
    @invalid_attrs %{email: nil, spot_id: nil}

    def subscriber_fixture(attrs \\ %{}) do
      {:ok, subscriber} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Domains.create_subscriber()

      subscriber
    end

    test "list_subscriber/0 returns all subscriber" do
      subscriber = subscriber_fixture()
      assert Domains.list_subscriber() == [subscriber]
    end

    test "get_subscriber!/1 returns the subscriber with given id" do
      subscriber = subscriber_fixture()
      assert Domains.get_subscriber!(subscriber.id) == subscriber
    end

    test "create_subscriber/1 with valid data creates a subscriber" do
      assert {:ok, %Subscriber{} = subscriber} = Domains.create_subscriber(@valid_attrs)
      assert subscriber.email == "some email"
      assert subscriber.spot_id == 42
    end

    test "create_subscriber/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Domains.create_subscriber(@invalid_attrs)
    end

    test "update_subscriber/2 with valid data updates the subscriber" do
      subscriber = subscriber_fixture()

      assert {:ok, %Subscriber{} = subscriber} =
               Domains.update_subscriber(subscriber, @update_attrs)

      assert subscriber.email == "some updated email"
      assert subscriber.spot_id == 43
    end

    test "update_subscriber/2 with invalid data returns error changeset" do
      subscriber = subscriber_fixture()
      assert {:error, %Ecto.Changeset{}} = Domains.update_subscriber(subscriber, @invalid_attrs)
      assert subscriber == Domains.get_subscriber!(subscriber.id)
    end

    test "delete_subscriber/1 deletes the subscriber" do
      subscriber = subscriber_fixture()
      assert {:ok, %Subscriber{}} = Domains.delete_subscriber(subscriber)
      assert_raise Ecto.NoResultsError, fn -> Domains.get_subscriber!(subscriber.id) end
    end

    test "change_subscriber/1 returns a subscriber changeset" do
      subscriber = subscriber_fixture()
      assert %Ecto.Changeset{} = Domains.change_subscriber(subscriber)
    end
  end
end
