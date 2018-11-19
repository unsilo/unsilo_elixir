  defmodule UnsiloWeb.Plugs.AssignUser do

    alias Plug.Conn

    def init(opts), do: opts

    def call(conn, _opts) do
      case Guardian.Plug.current_resource(conn) do
        nil ->
          conn
        {:ok, user} -> 
          Map.put(conn, :user, user)
        other -> IO.inspect(other, label: "other")
      end
    end
  end

