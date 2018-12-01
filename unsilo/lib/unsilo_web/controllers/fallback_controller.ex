defmodule UnsiloWeb.FallbackController do
  use UnsiloWeb, :controller

  def call(conn, {:error, msg}) when is_binary(msg) do
    conn
    |> put_flash(:error, msg)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def call(
        conn = %{
          assigns: %{
            authorized: false
          }
        },
        reason
      ) do
    conn
    |> put_flash(:error, reason)
    |> put_view(UnsiloWeb.FallbackView)
    |> render("unauthorized.json")
  end

  def action(
        conn = %{
          assigns: %{
            authorized: false
          }
        },
        _
      ) do
    conn
    |> put_view(UnsiloWeb.FallbackView)
    |> render("unauthorized.json")
  end

  def update(
        %{
          assigns: %{
            authorized: false
          }
        } = conn,
        _prms
      ) do
    conn
    |> put_view(UnsiloWeb.FallbackView)
    |> render("unauthorized.json")
  end
end
