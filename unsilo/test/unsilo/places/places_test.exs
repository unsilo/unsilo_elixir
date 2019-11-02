defmodule Unsilo.PlacesTest do
  use Unsilo.DataCase

  alias Unsilo.Places

  describe "locations" do
    alias Unsilo.Places.Location

    @valid_attrs %{address: "some address", lat: 120.5, lng: 120.5, name: "some name", phone: "some phone", type: 0}
    @update_attrs %{address: "some updated address", lat: 456.7, lng: 456.7, name: "some updated name", phone: "some updated phone", type: 1}
    @invalid_attrs %{address: nil, lat: nil, lng: nil, name: nil, phone: nil, type: nil}

    def location_fixture(attrs \\ %{}) do
      {:ok, location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Places.create_location()

      location
    end

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Places.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Places.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      assert {:ok, %Location{} = location} = Places.create_location(@valid_attrs)
      assert location.address == "some address"
      assert location.lat == 120.5
      assert location.lng == 120.5
      assert location.name == "some name"
      assert location.phone == "some phone"
      assert location.type == :remote
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Places.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      assert {:ok, %Location{} = location} = Places.update_location(location, @update_attrs)
      assert location.address == "some updated address"
      assert location.lat == 456.7
      assert location.lng == 456.7
      assert location.name == "some updated name"
      assert location.phone == "some updated phone"
      assert location.type == :local
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Places.update_location(location, @invalid_attrs)
      assert location == Places.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Places.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Places.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Places.change_location(location)
    end
  end
end
