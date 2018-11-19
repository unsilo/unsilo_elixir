defmodule UnsiloWeb.Controllers.ActionBtnHelpers do
  import Phoenix.Controller
  alias Unsilo.ActionBtnView

  def render_success(conn, template, assigns) do
    form_html = Phoenix.View.render_to_string(conn.private.phoenix_view, template, Keyword.merge([conn: conn], assigns))
   
    conn
    |> put_view(ActionBtnView)
    |> render("success.json", html: form_html)
  end

  def render_error(conn, template, assigns) do
    form_html = Phoenix.View.render_to_string(conn.private.phoenix_view, template, Keyword.merge([conn: conn, layout: false], assigns))

    conn
    |> put_view(ActionBtnView)
    |> render("error.json", html: form_html)
  end

  def render_success(conn) do
    conn
    |> put_view(ActionBtnView)
    |> render("success.json")
  end

  def render_error(conn) do
    conn
    |> put_view(ActionBtnView)
    |> render("error.json")
  end
end
