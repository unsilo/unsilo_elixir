defmodule UnsiloWeb.Plugs.AssignUser do
  alias Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      {:err, :not_found} ->
        conn

      {:ok, user} ->
        conn
        |> Conn.assign(:current_user, user)

      _other ->
        conn
    end
  end
end
