defmodule UnsiloWeb.StoryController do
  use UnsiloWeb, :controller

  alias Unsilo.Feeds
  alias Unsilo.Feeds.Story
  alias Plug.Conn

  plug :assign_sub_title

  plug :load_and_authorize_resource,
    model: Story,
    preload: :archive,
    only: [:index, :update, :delete]

  action_fallback UnsiloWeb.FallbackController

  use UnsiloWeb.AssignableController, assignable: :story

  def assign_sub_title(conn, _) do
    conn
    |> Conn.assign(:page_sub_title, "rivers")
    |> Conn.assign(:page_sub_title_url, Routes.river_path(conn, :index))
    |> Conn.assign(:new_item_url, Routes.river_path(conn, :new))
  end

  def index(conn, %{"mode" => story_mode}, user) do
    stories = Feeds.list_stories(story_mode, user)

    render(conn, "index.html", stories: stories, user: user, story_mode: story_mode)
  end

  def update(conn, %{"cmd" => story_cmd}, _user, story) do
    case story_cmd do
      "mark_read" ->
        story
        |> Feeds.update_story(%{read_at: DateTime.utc_now(), deleted_at: nil})
        |> case do
          {:ok, _story} ->
            render_success(conn, "empty.html", [])

          {:error, %Ecto.Changeset{} = _changeset} ->
            render_error(conn, "empty.html", [])
        end

      "mark_delete" ->
        story
        |> Feeds.update_story(%{deleted_at: DateTime.utc_now(), read_at: nil, archived_at: nil})
        |> case do
          {:ok, _story} ->
            render_success(conn, "empty.html", [])

          {:error, %Ecto.Changeset{} = _changeset} ->
            render_error(conn, "empty.html", [])
        end

      "mark_archive" ->
        story
        |> Feeds.create_archive()
        |> Feeds.update_story(%{archived_at: DateTime.utc_now()})
        |> case do
          {:ok, _story} ->
            render_success(conn, "empty.html", [])

          {:error, %Ecto.Changeset{} = _changeset} ->
            render_error(conn, "empty.html", [])
        end
    end
  end
end
