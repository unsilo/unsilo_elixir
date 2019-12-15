defmodule UnsiloWeb.NestLive do
  use Phoenix.HTML
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <div class="row">
        <h4 phx-click="view-nests" phx-value-uuid="1" phx-value-location_id="<%= @location_id %>">
          Nest
        </h4>
        <div id="nest_row" class="row live_row">
          <%= for thermostats <- @thermostats do %>
            <div class="card col-4 <%= nest_card_class(thermostats) %>">
              <h5 class="card-title">
                <%= thermostats.name %>
              </h5>
              <div class="row">
                <div class="col-12">
                  <%= thermostats.ambient_temperature_f %>
                  -
                  <%= thermostats.target_temperature_f %>
                </div>
                <div class="col-12">
                  <i class="fa fa-angle-double-up" phx-click="temp-up" phx-value-uuid="<%= thermostats.device_id %>" phx-value-api-key="<%= @api_key %>"></i>
                  <i class="fa fa-angle-double-down" phx-click="temp-down" phx-value-uuid="<%= thermostats.device_id %>" phx-value-api-key="<%= @api_key %>"></i>

                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    """
  end

  def mount(%{api_key: api_key, location_id: location_id}, socket) do
    WifiThermostat.thermostat_subscribe(api_key)

    socket = assign(socket, :api_key, api_key)
    socket = assign(socket, :location_id, location_id)
    {:ok, decorate_socket(socket)}
  end

  def handle_info(:nest_updated, socket) do
    IO.puts("notify arrived")
    {:noreply, decorate_socket(socket)}
  end

  def handle_info(an, state) do
    IO.inspect(an, label: "the unknown handle info")
    {:noreply, state}
  end

  def handle_event("temp-up", %{"uuid" => uuid, "api-key" => api_key}, %{assigns: %{thermostats: thermostats}} = socket) do
    increment_target_temp(1, uuid, api_key, thermostats)

    {:noreply, socket}
  end

  def handle_event("temp-down", %{"uuid" => uuid, "api-key" => api_key}, %{assigns: %{thermostats: thermostats}} = socket) do
    increment_target_temp(-1, uuid, api_key, thermostats)

    {:noreply, socket}
  end

  def handle_event("view-nests", %{"uuid" => uuid, "location_id" => location_id}, socket) do
    socket = live_redirect(socket, to: Routes.live_path(socket, UnsiloWeb.NestShowLive, %{uuid: uuid, location_id: location_id}))

    {:noreply, socket}
  end

  defp increment_target_temp(amt, uuid, api_key, thermostats) do
    this_therm =
      thermostats
      |> Enum.find(fn t -> t.device_id == uuid end)

    %{
      target_temperature_f: target_temperature_f
    } = this_therm

    WifiThermostat.set_target_temperature(uuid, api_key, target_temperature_f + amt)
  end

  defp decorate_socket(%{assigns: %{api_key: api_key}} = socket) do
    assign(socket,
      thermostats: WifiThermostat.get_thermostats(api_key)
    )
  end

  defp nest_card_class(%{hvac_state: "cooling"}) do
    "bg-primary"
  end

  defp nest_card_class(%{hvac_state: "heating"}) do
    "bg-danger"
  end

  defp nest_card_class(_) do
    ""
  end
end
