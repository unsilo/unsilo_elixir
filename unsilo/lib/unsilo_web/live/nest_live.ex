defmodule UnsiloWeb.NestLive do
  use Phoenix.HTML
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <div class="row">
        <h4>
          Nest
        </h4>
        <div id="nest_row" class="row live_row">
          <%= for nest <- @nests do %>
            <div class="card col-4 <%= nest_card_class(nest) %>">
              <h5 class="card-title">
                <%= nest.name %>
              </h5>
              <div class="row">
                <div class="col-12">
                  <%= nest.ambient_temperature_f %>
                  -
                  <%= nest.target_temperature_f %>
                </div>
                <div class="col-12">
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    """
  end

  def mount(%{api_key: api_key}, socket) do
    {:ok, _pid} = Registry.register(Nestex, "thermostats", [])

    socket = assign(socket, :api_key, api_key)
    {:ok, decorate_socket(socket)}
  end

  def handle_info({:updated, _new_devices}, socket) do
    {:noreply, decorate_socket(socket)}
  end

  defp decorate_socket(%{assigns: %{api_key: _api_key}} = socket) do
    assign(socket,
      nests: Nestex.get_thermostats()
    )
  end

  defp nest_card_class(%{hvac_mode: :cool, hvac_state: :on}) do
    "bg-primary"
  end

  defp nest_card_class(%{hvac_mode: :heat, hvac_state: :on}) do
    "bg-danger"
  end

  defp nest_card_class(_) do
    ""
  end

end
