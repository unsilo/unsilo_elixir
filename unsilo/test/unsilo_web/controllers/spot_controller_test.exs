defmodule UnsiloWeb.SpotControllerTest do
  use UnsiloWeb.ConnCase

  import Unsilo.Factory

  @update_attrs %{
    domains: "some updated domain",
  }
  @invalid_attrs %{domains: "qd", user_id: nil}

  setup do
    user = insert(:user)
    spot = insert(:spot, user_id: user.id)
    conn = Phoenix.ConnTest.build_conn
    |> UnsiloWeb.Auth.Guardian.Plug.sign_in(user)
    {:ok, conn: conn, user: user, spot: spot}
  end

  describe "index" do
    test "lists all spots", %{conn: conn} do
      conn = get(conn, Routes.spot_path(conn, :index))
      assert html_response(conn, 200) =~ "<a href=\"/\">sfuchs.fyi</a>/<a href=\"/spots\">spots</a>"
    end
  end


  describe "new spot" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.spot_path(conn, :new))
      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "New Spot"
    end
  end

  describe "create spot" do
    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn = post(conn, Routes.spot_path(conn, :create), spot: %{
        domains: "some domain",
        user_id: user.id
      })

      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "#spot_list"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.spot_path(conn, :create), spot: @invalid_attrs)
      assert %{"status" => "err", "html" => html} = json_response(conn, 200)
      assert html =~ "New Spot"
    end
  end

  describe "edit spot" do
    test "renders form for editing chosen spot", %{conn: conn, spot: spot} do
      conn = get(conn, Routes.spot_path(conn, :edit, spot))
      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "Edit Spot"
    end
  end

  describe "update spot" do
    test "redirects when data is valid", %{conn: conn, spot: spot} do
      conn = put(conn, Routes.spot_path(conn, :update, spot), spot: @update_attrs)
      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "#spot_list"
    end

    test "renders errors when data is invalid", %{conn: conn, spot: spot} do
      conn = put(conn, Routes.spot_path(conn, :update, spot), spot: @invalid_attrs)
      assert %{"status" => "err", "html" => html} = json_response(conn, 200)
      assert html =~ "Edit Spot"
    end
  end

  describe "delete spot" do
    test "deletes chosen spot", %{conn: conn, spot: spot} do
      conn = delete(conn, Routes.spot_path(conn, :delete, spot))
      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
    end
  end
end
