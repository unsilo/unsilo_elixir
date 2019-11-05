defmodule UnsiloWeb.SonosLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(UnsiloWeb.LocationView, "sonos_listing.html", assigns)
  end

  def mount(%{id: id, current_user_id: user_id}, socket) do
    players = Sonex.get_players() |> IO.inspect(label: "mounted the sonos")

    {:ok, assign(socket, :players, players)}
  end
end