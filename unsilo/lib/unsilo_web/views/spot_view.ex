defmodule UnsiloWeb.SpotView do
  use UnsiloWeb, :view

  alias Unsilo.Domains.Spot

  def get_logo_url(spot) do
    Unsilo.Logo.url({spot.logo, spot}, :thumb)
  end

  def display_title(spot) do
    spot.name || Enum.at(spot.domains, 0)
  end

  def background_color(%Spot{background_color: nil}) do
    "#55575c"
  end

  def background_color(%Spot{background_color: background_color}) do
    background_color
  end

  def subscriber_description(spot) do
    "#{Enum.count(spot.subscribers)} subscriptions"
  end
end
