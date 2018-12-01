defmodule UnsiloWeb.UserControllerTest do
  use UnsiloWeb.ConnCase
  import Ecto.Query, warn: false
  import Unsilo.Factory

  @create_attrs %{password: "some encrypted_password", email: "some email"}
  @update_attrs %{password: "some updated encrypted_password", email: "email updated email"}
  @invalid_attrs %{password: nil, email: nil}

  setup do
    user = insert(:user)
    admin_user = insert(:user, role: :admin)
    other_user = insert(:user)

    conn = Phoenix.ConnTest.build_conn()

    {:ok, [conn: conn, admin_user: admin_user, user: user, other_user: other_user]}
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert inspect(json_response(conn, 200)) =~ "Sign Up"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert json_response(conn, 200) == %{"status" => "ok"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)

      assert inspect(json_response(conn, 200)) =~ "Sign up Failed"
      assert inspect(json_response(conn, 200)) =~ "Sign Up"
    end
  end

  describe "logged in users cant create new users" do
    setup [:login_user]

    test "can't render new form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert %{"status" => "err"} = json_response(conn, 200)
    end

    test "can't create new user", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert %{"status" => "err"} = json_response(conn, 200)
    end
  end

  describe "edit user" do
    setup [:login_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "Edit User"
    end

    test "cant render form for other user user", %{conn: conn, other_user: other_user} do
      conn = get(conn, Routes.user_path(conn, :edit, other_user))
      assert %{"status" => "err", "html" => "unauthorized"} = json_response(conn, 200)
    end
  end

  describe "update user" do
    setup [:login_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert json_response(conn, 200) == %{"status" => "ok"}
    end

    test "cant update another user", %{conn: conn, other_user: other_user} do
      conn = put(conn, Routes.user_path(conn, :update, other_user), user: @update_attrs)
      assert %{"status" => "err", "html" => "unauthorized"} = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert %{"status" => "err"} = json_response(conn, 200)
      assert inspect(json_response(conn, 200)) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:login_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      assert Unsilo.Repo.one(from u in "users", select: count(u.id)) == 3

      _conn = delete(conn, Routes.user_path(conn, :delete, user))

      assert Unsilo.Repo.one(from u in "users", select: count(u.id)) == 2
    end

    test "cant delete another user", %{conn: conn, other_user: other_user} do
      assert Unsilo.Repo.one(from u in "users", select: count(u.id)) == 3

      _conn = delete(conn, Routes.user_path(conn, :delete, other_user))

      assert Unsilo.Repo.one(from u in "users", select: count(u.id)) == 3
    end
  end

  describe "admin has power over all" do
    setup [:login_admin]

    test "can delete another user", %{conn: conn, other_user: other_user} do
      conn = delete(conn, Routes.user_path(conn, :delete, other_user))
      assert %{"status" => "ok"} = json_response(conn, 200)
    end

    test "can update another user", %{conn: conn, other_user: other_user} do
      conn = put(conn, Routes.user_path(conn, :update, other_user), user: @update_attrs)
      assert %{"status" => "ok"} = json_response(conn, 200)
    end

    test "can edit another user", %{conn: conn, other_user: other_user} do
      conn = get(conn, Routes.user_path(conn, :edit, other_user))

      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "Edit User"
    end
  end

  defp login_admin(%{conn: conn, admin_user: admin_user} = ctxt) do
    conn = UnsiloWeb.Auth.Guardian.Plug.sign_in(conn, admin_user)

    {:ok, Map.merge(ctxt, %{conn: conn})}
  end

  defp login_user(%{conn: conn, user: user} = ctxt) do
    conn = UnsiloWeb.Auth.Guardian.Plug.sign_in(conn, user)

    {:ok, Map.merge(ctxt, %{conn: conn})}
  end
end
