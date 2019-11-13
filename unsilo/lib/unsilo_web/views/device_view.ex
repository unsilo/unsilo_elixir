defmodule UnsiloWeb.DeviceView do
  use UnsiloWeb, :view

  def new_form_for_type("sonos") do
    "/forms/new_sonos.html"
  end
end
