defmodule UnsiloWeb.RainMachineLive do
  use Phoenix.HTML
  use Phoenix.LiveView

  def render(%{device: nil} = assigns) do
    ~L"""
      <div class="row">
        <h4>
          RainMaster
        </h4>
        <div id="rain_master_row" class="row live_row">
          offline
        </div>
      </div>
    """
  end

  def render(assigns) do
    ~L"""
      <div class="row">
        <h4>
          RainMaster
        </h4>
        <div id="rain_master_row" class="row live_row">
          <%= for zone <- @device.zones do %>
            <div class="card col-4 <%= watering_card_class(zone) %>">
              <h5 class="card-title">
                <%= zone.name %>
              </h5>
              <div class="row">
                <div class="col-4">
                  <%= draw_player_btn(@device, zone) %>
                </div>
                <div class="col-8">
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    """
  end

  def mount(%{ip_address: ip_address, password: password}, socket) do
    RainMachine.device_subscribe(ip_address, password)

    socket =
      assign(socket,
        ip_address: ip_address
      )

    {:ok, decorate_socket(socket)}
  end

  def handle_info(:rainmachine_update, socket) do
    IO.puts("rainmachine_update arrived")
    {:noreply, decorate_socket(socket)}
  end

  def handle_info(an, state) do
    IO.inspect(an, label: "the unknown handle info")
    {:noreply, state}
  end

  def handle_event("stop_watering", %{"uuid" => uuid, "ip" => ip_addr}, socket) do
    device = RainMachine.get_device(ip_addr)
    zone = RainMachine.get_zone(device, uuid)
    RainMachine.stop_zone(device, zone)

    {:noreply, socket}
  end

  def handle_event("start_watering", %{"uuid" => uuid, "ip" => ip_addr}, socket) do
    device = RainMachine.get_device(ip_addr)
    zone = RainMachine.get_zone(device, uuid)

    RainMachine.start_zone(device, zone)
    {:noreply, socket}
  end

  defp decorate_socket(%{assigns: %{ip_address: ip_address}} = socket) do
    assign(socket,
      device: RainMachine.get_device(ip_address)
    )
  end

  defp watering_card_class(%{state: 1}) do
    "bg-primary"
  end

  defp watering_card_class(_) do
    ""
  end

  defp draw_player_btn(%{ip_address: ip_address}, %{state: 0, uid: uid}) do
    ~E"""
    <i class="fa fa-play" phx-click="start_watering" phx-value-uuid="<%= uid %>" phx-value-ip="<%= ip_address %>"></i>
    """
  end

  defp draw_player_btn(%{ip_address: _ip_address}, %{state: 2, uid: _uid}) do
    ~E"""
    <i class="fa fa-spinner"></i>
    """
  end

  defp draw_player_btn(%{ip_address: ip_address}, %{state: 1, uid: uid}) do
    ~E"""
    <i class="fa fa-stop" phx-click="stop_watering" phx-value-uuid="<%= uid %>" phx-value-ip="<%= ip_address %>"></i>
    """
  end
end
