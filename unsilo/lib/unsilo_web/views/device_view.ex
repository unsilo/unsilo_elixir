defmodule UnsiloWeb.DeviceView do
  use UnsiloWeb, :view

  def new_form_for_type("sonos") do
    "/forms/new_sonos.html"
  end

  def the_test_div(%{interval: interval}) do
    contents =
      ~w(minute hour day week month)
      |> Enum.map(fn n ->
        if n == interval, do: "<option selected>#{n}</option>", else: "<option>#{n}</option>"
      end)
      |> raw

    content_tag(:select, contents, name: "interval")
  end
end
