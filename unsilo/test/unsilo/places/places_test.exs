defmodule Unsilo.PlacesTest do
  use Unsilo.DataCase

  alias Unsilo.Places

  describe "devices" do
    alias Unsilo.Places.Device

    @valid_attrs %{
      app_key: "some app_key",
      name: "some name",
      sort_order: 42,
      status: "some status",
      unsilo_uuid: "some unsilo_uuid",
      uuid: "some uuid"
    }
    @update_attrs %{
      app_key: "some updated app_key",
      name: "some updated name",
      sort_order: 43,
      status: "some updated status",
      unsilo_uuid: "some updated unsilo_uuid",
      uuid: "some updated uuid"
    }
    @invalid_attrs %{
      app_key: nil,
      name: nil,
      sort_order: nil,
      status: nil,
      unsilo_uuid: nil,
      uuid: nil
    }

    def device_fixture(attrs \\ %{}) do
      {:ok, device} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Places.create_device()

      device
    end

    test "list_devices/0 returns all devices" do
      device = device_fixture()
      assert Places.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = device_fixture()
      assert Places.get_device!(device.id) == device
    end

    test "create_device/1 with valid data creates a device" do
      assert {:ok, %Device{} = device} = Places.create_device(@valid_attrs)
      assert device.app_key == "some app_key"
      assert device.name == "some name"
      assert device.sort_order == 42
      assert device.status == "some status"
      assert device.unsilo_uuid == "some unsilo_uuid"
      assert device.uuid == "some uuid"
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Places.create_device(@invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = device_fixture()
      assert {:ok, %Device{} = device} = Places.update_device(device, @update_attrs)
      assert device.app_key == "some updated app_key"
      assert device.name == "some updated name"
      assert device.sort_order == 43
      assert device.status == "some updated status"
      assert device.unsilo_uuid == "some updated unsilo_uuid"
      assert device.uuid == "some updated uuid"
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = device_fixture()
      assert {:error, %Ecto.Changeset{}} = Places.update_device(device, @invalid_attrs)
      assert device == Places.get_device!(device.id)
    end

    test "delete_device/1 deletes the device" do
      device = device_fixture()
      assert {:ok, %Device{}} = Places.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> Places.get_device!(device.id) end
    end

    test "change_device/1 returns a device changeset" do
      device = device_fixture()
      assert %Ecto.Changeset{} = Places.change_device(device)
    end
  end

  describe "locations" do
    alias Unsilo.Places.Location

    @valid_attrs %{
      address: "some address",
      lat: 120.5,
      lng: 120.5,
      name: "some name",
      phone: "some phone",
      type: 0
    }
    @update_attrs %{
      address: "some updated address",
      lat: 456.7,
      lng: 456.7,
      name: "some updated name",
      phone: "some updated phone",
      type: 1
    }
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
