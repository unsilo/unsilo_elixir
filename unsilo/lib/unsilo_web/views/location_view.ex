defmodule UnsiloWeb.LocationView do
  use UnsiloWeb, :view

  alias Unsilo.Places.Device

  def get_place_pic_thumb(place) do
    Unsilo.PlacePic.url({place.logo, place}, :thumb)
  end

  def get_place_pic_url(place) do
    Unsilo.PlacePic.url({place.logo, place}, :medium)
  end

  def new_device_menu(conn, devices) do
    ~E"""
      <div class="dropdown">
        <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          Add
        </button>
        <div class="dropdown-menu">
          <%= for dev <- devices do %>
            <a class="dropdown-item action_btn" href="#" data-modal-src-url="<%= Routes.device_path(conn, :new, %{type: dev.type}) %>" data-success-dom-dest=".new_dev_dest">
              <%= "Add #{dev.name}" %>
            </a>
          <% end %>
        </div>
      </div>
    """
  end

  def all_devices do
    [
      %Device{name: "Sonos", type: :sonos},
      %Device{name: "Nest", type: :nest},
    ]
  end
end
