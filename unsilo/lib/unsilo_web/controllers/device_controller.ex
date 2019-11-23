defmodule UnsiloWeb.DeviceController do
  use UnsiloWeb, :controller

  alias Unsilo.Places
  alias Unsilo.Places.Device

  def index(conn, _params) do
    devices = Places.list_devices()
    render(conn, "index.html", devices: devices)
  end

  def new(conn, %{"type" => type}) do
    changeset = Places.change_device(%Device{})
    render_new_device_form(conn, [changeset: changeset], %{type: type})
  end

  def create(conn, %{"device" => device_params}) do
    case Places.create_device(device_params) do
      {:ok, device} ->
        conn
        |> put_flash(:info, "Device created successfully.")
        |> redirect(to: Routes.device_path(conn, :show, device))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    device = Places.get_device!(id)
    render(conn, "show.html", device: device)
  end

  def edit(conn, %{"id" => id}) do
    device = Places.get_device!(id)
    changeset = Places.change_device(device)
    render(conn, "edit.html", device: device, changeset: changeset)
  end

  def update(conn, %{"id" => id, "device" => device_params}) do
    device = Places.get_device!(id)

    case Places.update_device(device, device_params) do
      {:ok, device} ->
        conn
        |> put_flash(:info, "Device updated successfully.")
        |> redirect(to: Routes.device_path(conn, :show, device))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", device: device, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    device = Places.get_device!(id)
    {:ok, _device} = Places.delete_device(device)

    conn
    |> put_flash(:info, "Device deleted successfully.")
    |> redirect(to: Routes.device_path(conn, :index))
  end

  defp render_new_device_form(conn, assigns, %{type: "sonos"}) do
    render_success(conn, "new_sonos.html", assigns)
  end

  defp render_new_device_form(conn, assigns, %{type: "nest"}) do
    render_success(conn, "new_nest.html", assigns)
  end

  defp render_new_device_form(conn, assigns, %{type: "rain_machine"}) do
    render_success(conn, "new_rain_machine.html", assigns)
  end
end
