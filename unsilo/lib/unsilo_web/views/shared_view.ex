defmodule UnsiloWeb.SharedView do
  use UnsiloWeb, :view

  def array_input(form, field) do
    values = Phoenix.HTML.Form.input_value(form, field) || [""]
    id = Phoenix.HTML.Form.input_id(form,field)
    type = Phoenix.HTML.Form.input_type(form, field)
    content_tag(:textarea, Enum.join(values, "\n"), name: "spot[domains]", id: container_id(id), class: "input_container")
  end

  defp container_id(id), do: id <> "_container"
end
