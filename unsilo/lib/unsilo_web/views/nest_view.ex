defmodule UnsiloWeb.NestView do
  use UnsiloWeb, :view


  def interval_select_tag(%{interval: interval}) do
    contents =
      ~w(minute hour day week month)
      |> Enum.map(fn n ->
        if n == interval, do: "<option selected>#{n}</option>", else: "<option>#{n}</option>"
      end)
      |> raw

    content_tag(:select, contents, name: "interval")
  end
end
