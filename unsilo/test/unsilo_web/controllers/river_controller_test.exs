defmodule UnsiloWeb.RiverControllerTest do
  import Unsilo.Factory

  use UnsiloWeb.ConnCase

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  setup do
    user = insert(:user)
    admin_user = insert(:user, role: :admin)
    other_user = insert(:user)
    river = insert(:river, user_id: user.id, name: "public_river")
    _private_river = insert(:river, user_id: user.id, access: :private, name: "private_river")
    feed = insert(:feed, user_id: user.id, river_id: river.id)

    conn = Phoenix.ConnTest.build_conn()

    {:ok,
     [
       conn: conn,
       admin_user: admin_user,
       user: user,
       other_user: other_user,
       river: river,
       feed: feed
     ]}
  end

  describe "index" do
    setup [:login_user]

    test "lists all rivers", %{conn: conn} do
      conn = get(conn, Routes.river_path(conn, :index))
      html = html_response(conn, 200)

      assert html =~ "all_rivers_list"
      assert html =~ "public_river"
      assert html =~ "private_river"
    end
  end

  describe "index when not logged in" do
    test "lists all rivers", %{conn: conn} do
      conn = get(conn, Routes.river_path(conn, :index))
      html = html_response(conn, 200)

      assert html =~ "all_rivers_list"
      assert html =~ "public_river"
      refute html =~ "private_river"
    end
  end

  describe "new river" do
    setup [:login_user]

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.river_path(conn, :new))

      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "Add a New River"
    end
  end

  describe "create river" do
    setup [:login_user]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.river_path(conn, :create), river: @create_attrs)

      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "river_tabs"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.river_path(conn, :create), river: @invalid_attrs)

      assert %{"status" => "err", "html" => html} = json_response(conn, 200)
      assert html =~ "Add a New River"
    end
  end

  describe "edit river" do
    setup [:login_user]

    test "renders form for editing chosen river", %{conn: conn, river: river} do
      conn = get(conn, Routes.river_path(conn, :edit, river))

      assert html_response(conn, 200) =~ "Edit River"
    end
  end

  describe "update river" do
    setup [:login_user]

    test "redirects when data is valid", %{conn: conn, river: river} do
      conn = put(conn, Routes.river_path(conn, :update, river), river: @update_attrs)

      assert redirected_to(conn) == Routes.river_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn, river: river} do
      conn = put(conn, Routes.river_path(conn, :update, river), river: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit River"
    end
  end

  describe "delete river" do
    setup [:login_user]

    test "deletes chosen river", %{conn: conn, river: river} do
      conn = delete(conn, Routes.river_path(conn, :delete, river))

      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "river_tabs"
    end
  end
end
