defmodule UnsiloWeb.NestShowLive do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias Unsilo.Places.Series.NestHeat

  def render(assigns) do
    Phoenix.View.render(UnsiloWeb.DeviceView, "nest_show_live.html", assigns)
  end

  def mount(%{location_id: location_id, uuid: uuid}, socket) do
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

  defp decorate_socket(%{assigns: %{}} = socket) do
    socket
    |> assign(start: NestHeat.get_earliest())
    |> assign(finish: NestHeat.get_latest())
    |> assign(uuids: NestHeat.get_uuids())
  end

  defp redecorate_socket(%{assigns: %{uuid: uuid}} = socket) do
      "SELECT first(avg_temp),last(avg_temp) FROM nest_thermostat"
      |> Unsilo.InfluxConnection.query(database: "unsilo_influx_database")
      |> IO.inspect
      |> handle_influx_results(socket)
  end

  defp handle_influx_results(%{results: [%{series: [%{values: dates}]}]}, socket) do

    assign(socket, dates: dates)
  end

  defp handle_influx_results(%{results: [%{statement_id: 0}]}, socket) do
    assign(socket, dates: [])
  end

end
