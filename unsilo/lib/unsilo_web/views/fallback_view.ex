defmodule UnsiloWeb.FallbackView do
  use UnsiloWeb, :view

  def render("unauthorized.json", _assigns) do
    %{"status" => "err", "html" => "unauthorized"}
  end
end
