defmodule UnsiloWeb.DashboardController do
  use UnsiloWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
