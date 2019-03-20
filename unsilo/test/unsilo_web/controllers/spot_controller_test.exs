defmodule UnsiloWeb.SpotControllerTest do
  use UnsiloWeb.ConnCase

  import Unsilo.Factory

  @update_attrs %{
    domains: "some updated domain"
  }
  @invalid_attrs %{domains: "qd", user_id: nil}

  setup do
    user = insert(:user)
    admin_user = insert(:user, role: :admin)
    other_user = insert(:user)
    spot = insert(:spot, user_id: user.id)

    conn = Phoenix.ConnTest.build_conn()

    {:ok, [conn: conn, admin_user: admin_user, user: user, other_user: other_user, spot: spot]}
  end

  describe "index" do
    setup [:login_user]

    test "lists all spots", %{conn: conn} do
      conn = get(conn, Routes.spot_path(conn, :index))

      assert html_response(conn, 200) =~
               "<a href=\"/\">sfuchs.fyi</a>/<a href=\"/spots\">spots</a>"
    end
  end

  describe "new spot" do
    setup [:login_user]

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.spot_path(conn, :new))
      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "New Spot"
    end
  end

  describe "create spot" do
    setup [:login_user]

    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.spot_path(conn, :create),
          spot: %{
            domains: "some domain",
            user_id: user.id
          }
        )

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
    setup [:login_user]

    test "renders form for editing chosen spot", %{conn: conn, spot: spot} do
      conn = get(conn, Routes.spot_path(conn, :edit, spot))
      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "Edit Spot"
    end

    test "cant edit spot created by another user", %{conn: conn, other_user: other_user} do
      other_spot = insert(:spot, user_id: other_user.id)
      conn = get(conn, Routes.spot_path(conn, :edit, other_spot))

      assert %{"status" => "err", "html" => "unauthorized"} = json_response(conn, 200)
    end
  end

  describe "show spot" do
    setup [:login_user]

    test "shows chosen spot", %{conn: conn, spot: spot} do
      conn = get(conn, Routes.spot_path(conn, :show, spot))
      assert html_response(conn, 200) =~ Enum.at(spot.domains, 0)
    end

    test "cant show spot created by another user", %{conn: conn, other_user: other_user} do
      other_spot = insert(:spot, user_id: other_user.id)
      conn = get(conn, Routes.spot_path(conn, :show, other_spot))

      assert %{"status" => "err", "html" => "unauthorized"} = json_response(conn, 200)
    end
  end

  describe "update spot" do
    setup [:login_user]

    test "renders data when update is valid", %{conn: conn, spot: spot} do
      conn = put(conn, Routes.spot_path(conn, :update, spot), spot: @update_attrs)
      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "#spot_list"
    end

    test "renders errors when data is invalid", %{conn: conn, spot: spot} do
      conn = put(conn, Routes.spot_path(conn, :update, spot), spot: @invalid_attrs)
      assert %{"status" => "err", "html" => html} = json_response(conn, 200)
      assert html =~ "Edit Spot"
    end

    test "renders errors when user doesnt own spot", %{conn: conn, other_user: other_user} do
      other_spot = insert(:spot, user_id: other_user.id)

      conn = put(conn, Routes.spot_path(conn, :update, other_spot), spot: @update_attrs)
      assert %{"status" => "err", "html" => "unauthorized"} = json_response(conn, 200)
    end
  end

  describe "delete spot" do
    setup [:login_user]

    test "deletes chosen spot", %{conn: conn, spot: spot} do
      conn = delete(conn, Routes.spot_path(conn, :delete, spot))
      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
    end

    test "cant delete someone elses chosen spot", %{conn: conn, other_user: other_user} do
      other_spot = insert(:spot, user_id: other_user.id)

      conn = delete(conn, Routes.spot_path(conn, :delete, other_spot))
      assert %{"status" => "err", "html" => "unauthorized"} = json_response(conn, 200)
    end
  end

  describe "admin has power over all" do
    setup [:login_admin]

    test "can delete someone elses spot", %{conn: conn, other_user: other_user} do
      other_spot = insert(:spot, user_id: other_user.id)

      conn = delete(conn, Routes.spot_path(conn, :delete, other_spot))
      assert %{"status" => "ok", "html" => ""} = json_response(conn, 200)
    end

    test "can update someone elses spot", %{conn: conn, other_user: other_user} do
      other_spot = insert(:spot, user_id: other_user.id)

      conn = put(conn, Routes.spot_path(conn, :update, other_spot), spot: @update_attrs)
      assert %{"status" => "ok", "html" => ""} = json_response(conn, 200)
    end

    test "can edit spot created by another user", %{conn: conn, other_user: other_user} do
      other_spot = insert(:spot, user_id: other_user.id)
      conn = get(conn, Routes.spot_path(conn, :edit, other_spot))

      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "Edit Spot"
    end

    test "can show spot created by another user", %{conn: conn, other_user: other_user} do
      other_spot = insert(:spot, user_id: other_user.id)
      conn = get(conn, Routes.spot_path(conn, :show, other_spot))

      assert html_response(conn, 200) =~ Enum.at(other_spot.domains, 0)
    end
  end

  defp login_admin(%{conn: conn, admin_user: admin_user} = ctxt) do
    conn = UnsiloWeb.Auth.Guardian.Plug.sign_in(conn, admin_user)

    {:ok, Map.merge(ctxt, %{conn: conn})}
  end
end
