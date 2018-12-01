defmodule UnsiloWeb.Plugs.DomainSpot do
  alias Plug.Conn
  alias Phoenix.View
  alias Unsilo.Domains

  def init(opts), do: opts

  def call(conn, _opts) do
    case Domains.spot_for_domain(conn.host) do
      nil ->
        conn

      spot ->
        Domains.increment_spot_count(spot)
        body = View.render_to_string(UnsiloWeb.SpotView, theme_name(spot), conn: conn, spot: spot)

        conn
        |> Conn.update_resp_header(
          "content-type",
          "text/html; charset=utf-8",
          &(&1 <> "; charset=utf-8")
        )
        |> Conn.send_resp(200, body)
        |> Conn.halt()
    end
  end

  defp theme_name(%{theme: nil}) do
    "centered.html"
  end

  defp theme_name(%{theme: theme}) do
    "#{theme}.html"
  end
end
