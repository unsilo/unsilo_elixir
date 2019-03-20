defmodule UnsiloWeb.RiverView do
  use UnsiloWeb, :view

  import Canada, only: [can?: 2]

  def sorted_stories(stories) do
    Enum.sort(stories, fn x, y ->
      case NaiveDateTime.compare(x.inserted_at, y.inserted_at) do
        :gt -> true
        _ -> false
      end
    end)
  end
end
