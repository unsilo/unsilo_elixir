defmodule UnsiloWeb.PageControllerTest do
  use UnsiloWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "sfuchs.fyi"
  end
end
