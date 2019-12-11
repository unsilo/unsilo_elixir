defmodule UnsiloWeb.SonosLive do
  use Phoenix.HTML
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <div class="row">
        <h4>
          Sonos
        </h4>
        <div id="sonos_row" class="row live_row">
          <%= for player <- @players do %>
            <div class="card col-4">
              <h5 class="card-title">
                <%= player.name %>
              </h5>
              <div class="row">
                <div class="col-4">
                  <%= draw_player_btn(player) %>
                </div>
                <div class="col-20">
                  <%= draw_player_vol(player) %>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    """
  end

  def mount(sess, socket) do
    {:ok, _pid} = Registry.register(Sonex, "devices", [])

    {:ok, decorate_socket(socket)}
  end

  def handle_info({:discovered, _new_device}, socket) do
    {:noreply, decorate_socket(socket)}
  end

  def handle_info({:updated, _new_device}, socket) do
    {:noreply, decorate_socket(socket)}
  end

  def handle_event("pause-device", %{"uuid" => uuid}, socket) do
    Sonex.get_player(uuid)
    |> Sonex.stop_player()

    {:noreply, socket}
  end

  def handle_event("play-device", %{"uuid" => uuid}, socket) do
    Sonex.get_player(uuid)
    |> Sonex.start_player()

    {:noreply, socket}
  end

  def handle_event("volume-slider", %{"uuid" => uuid, "value" => value}, socket) do
    Sonex.get_player(uuid)
    |> Sonex.set_volume(value)

    {:noreply, socket}
  end

  defp draw_player_vol(%{uuid: uuid, player_state: %{volume: nil}}) do
    ""
  end

  defp draw_player_vol(%{uuid: uuid, player_state: %{volume: %{m: vol}}}) do
    ~E"""
      <input type="range" name="volume" min="0" max="100" value="<%= vol %>" class="slider" phx-click="volume-slider" phx-value-uuid="<%= uuid %>">
    """
  end

  defp draw_player_btn(%{uuid: uuid, player_state: %{current_state: "STOPPED"}}) do
    ~E"""
    <i class="fa fa-play" phx-click="play-device" phx-value-uuid="<%= uuid %>"></i>
    """
  end

  defp draw_player_btn(%{player_state: %{current_state: "TRANSITIONING"}}) do
    ~E"""
    <i class="fa fa-spinner"></i>
    """
  end

  defp draw_player_btn(%{uuid: uuid, player_state: %{current_state: "PLAYING"}}) do
    ~E"""
    <i class="fa fa-stop" phx-click="pause-device" phx-value-uuid="<%= uuid %>"></i>
    """
  end

  defp draw_player_btn(), do: ""

  defp decorate_socket(socket) do
    assign(socket,
      players: Sonex.get_players()
    )
  end
end
