defmodule UnsiloWeb.SessionControllerTest do
  use UnsiloWeb.ConnCase

  import Unsilo.Factory
  
  @create_attrs %{"email" => "some email", "password" => "some password"}
  @invalid_attrs %{"email" => "", "password" => "some updated password"}

  setup do
    user = insert(:user, %{email: "some email",
                          password_hash: "some hashed password"})
    {:ok, user: user}
  end

  describe "new session" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :new))

      assert inspect(json_response(conn, 200)) =~ "Log in"
    end
  end

  describe "create session" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), user: @create_attrs)

      inspect(json_response(conn, 200)) =~ "sfuchs.qq  endq  fyi"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), user: @invalid_attrs)
      assert inspect(json_response(conn, 200)) =~ "Login Failed"
    end
  end
end
