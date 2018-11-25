defmodule UnsiloWeb.UserControllerTest do
  use UnsiloWeb.ConnCase
  import Ecto.Query, warn: false

  alias Unsilo.Accounts

  @create_attrs %{password: "some encrypted_password", email: "some email"}
  @update_attrs %{password: "some updated encrypted_password", email: "email updated email"}
  @invalid_attrs %{password: nil, email: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
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

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = UnsiloWeb.Auth.Guardian.Plug.sign_in(conn, user)

      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = UnsiloWeb.Auth.Guardian.Plug.sign_in(conn, user)

      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert json_response(conn, 200) == %{"status" => "ok"}
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = UnsiloWeb.Auth.Guardian.Plug.sign_in(conn, user)

      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert %{"status" => "err"} = json_response(conn, 200)
      assert inspect(json_response(conn, 200)) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = UnsiloWeb.Auth.Guardian.Plug.sign_in(conn, user)

      _conn = delete(conn, Routes.user_path(conn, :delete, user))

      assert Unsilo.Repo.one(from u in "users", select: count(u.id)) == 0
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
