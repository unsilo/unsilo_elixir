defmodule UnsiloWeb.LocationControllerTest do
  import Unsilo.Factory

  use UnsiloWeb.ConnCase

  @create_attrs %{
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

  setup do
    user = insert(:user)
    location = insert(:location, user_id: user.id, name: "public location")

    conn = Phoenix.ConnTest.build_conn()

    {:ok,
     %{
       conn: conn,
       user: user,
       location: location
     }}
  end

  describe "index" do
    test "lists all locations", %{conn: conn} do
      conn = get(conn, Routes.location_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Locations"
    end
  end

  describe "new location" do
    setup [:login_user]

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.location_path(conn, :new))
      assert html_response(conn, 200) =~ "New Location"
    end
  end

  describe "create location" do
    setup [:login_user]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.location_path(conn, :create), location: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.location_path(conn, :show, id)

      conn = get(conn, Routes.location_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Location"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.location_path(conn, :create), location: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Location"
    end
  end

  describe "edit location" do
    setup [:login_user]

    test "renders form for editing chosen location", %{conn: conn, location: location} do
      conn = get(conn, Routes.location_path(conn, :edit, location))
      assert html_response(conn, 200) =~ "Edit Location"
    end
  end

  describe "update location" do
    setup [:login_user]

    test "redirects when data is valid", %{conn: conn, location: location} do
      conn = put(conn, Routes.location_path(conn, :update, location), location: @update_attrs)
      assert redirected_to(conn) == Routes.location_path(conn, :show, location)

      conn = get(conn, Routes.location_path(conn, :show, location))
      assert html_response(conn, 200) =~ "some updated address"
    end

    test "renders errors when data is invalid", %{conn: conn, location: location} do
      conn = put(conn, Routes.location_path(conn, :update, location), location: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Location"
    end
  end

  describe "delete location" do
    setup [:login_user]

    test "deletes chosen location", %{conn: conn, location: location} do
      conn = delete(conn, Routes.location_path(conn, :delete, location))
      assert redirected_to(conn) == Routes.location_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.location_path(conn, :show, location))
      end
    end
  end
end
