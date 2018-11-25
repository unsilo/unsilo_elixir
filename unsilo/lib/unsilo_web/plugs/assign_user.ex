defmodule UnsiloWeb.Plugs.AssignUser do
  def init(opts), do: opts

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      {:err, :not_found} ->
        conn

      {:ok, user} ->
        Map.put(conn, :user, user)

      _other ->
        conn
    end
  end
end
