defmodule UnsiloWeb.LocationView do
  use UnsiloWeb, :view


  def get_place_pic_thumb(place) do
    Unsilo.PlacePic.url({place.logo, place}, :thumb)
  end

  def get_place_pic_url(place) do
    Unsilo.PlacePic.url({place.logo, place}, :medium)
  end

  def render("show.html", %{location: %{type: :local}} = assigns) do
    render("local.html", assigns)
  end
end
