defmodule UnsiloWeb.StoryView do
  use UnsiloWeb, :view

  import Canada, only: [can?: 2]

  alias Unsilo.Feeds.Story
  alias Timex.Format.DateTime.Formatters.Relative

  def get_story_type("read"), do: "Marked for Reading"

  def get_story_type("archived"), do: "Archived"

  def get_story_type("deleted"), do: "Deleted"

  def sorted_stories(stories, "read") do
    Enum.sort(stories, fn x, y ->
      case DateTime.compare(x.read_at, y.read_at) do
        :gt -> true
        _ -> false
      end
    end)
  end

  def sorted_stories(stories, "archived") do
    Enum.sort(stories, fn x, y ->
      case DateTime.compare(x.archived_at, y.archived_at) do
        :gt -> true
        _ -> false
      end
    end)
  end

  def sorted_stories(stories, "deleted") do
    Enum.sort(stories, fn x, y ->
      case DateTime.compare(x.deleted_at, y.deleted_at) do
        :gt -> true
        _ -> false
      end
    end)
  end

  def draw_story_date(%Story{
        deleted_at: nil,
        archived_at: nil,
        read_at: nil,
        inserted_at: inserted_at
      }) do
    Relative.format!(inserted_at, "added {relative}")
  end

  def draw_story_date(%Story{deleted_at: deleted_at, archived_at: nil, read_at: nil}) do
    Relative.format!(deleted_at, "deleted {relative}")
  end

  def draw_story_date(%Story{deleted_at: nil, archived_at: archived_at, read_at: nil}) do
    Relative.format!(archived_at, "archived {relative}")
  end

  def draw_story_date(%Story{deleted_at: nil, archived_at: nil, read_at: read_at}) do
    Relative.format!(read_at, "marked for reading {relative}")
  end

  def draw_story_date(%Story{} = story) do
    "error in #{inspect(story)}"
  end
end
