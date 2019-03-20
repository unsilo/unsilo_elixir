defmodule UnsiloWeb.AssignableController do
  defmacro __using__([assignable: assignable] = _opts) do
    quote do
      def action(%{assigns: %{current_user: user} = assigns} = conn, _) do
        args =
          case Map.get(assigns, unquote(assignable)) do
            nil ->
              [conn, conn.params, user]

            subject ->
              [conn, conn.params, user, subject]
          end

        apply(__MODULE__, action_name(conn), args)
      end

      def action(conn, _) do
        args = [conn, conn.params]

        apply(__MODULE__, action_name(conn), args)
      end
    end
  end
end
