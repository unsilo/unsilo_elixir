defmodule UnsiloWeb.FeedController do
  use UnsiloWeb, :controller

  alias Unsilo.Feeds
  alias Unsilo.Feeds.Feed
  alias Unsilo.Feeds.River

  plug(:load_and_authorize_resource,
    model: Feed,
    only: [:new, :create, :delete]
  )

  action_fallback(UnsiloWeb.FallbackController)

  use UnsiloWeb.AssignableController, assignable: :feed

  def new(conn, %{"river_id" => river_id}, _user) do
    changeset = Feeds.change_feed(%Feed{river_id: river_id})

    render_success(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"feed" => %{"river_id" => river_id} = feed_params}, %{id: user_id} = user) do
    feed_params
    |> Map.put("user_id", user_id)
    |> Feeds.create_feed()
    |> case do
      {:ok, _feed} ->
        feeds = Feeds.list_feeds(%River{id: river_id})
        render_success(conn, "_listing.html", conn: conn, user: user, feeds: feeds)

      {:error, %Ecto.Changeset{} = changeset} ->
        render_error(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, _prms, user, %Feed{river_id: river_id} = feed) do
    {:ok, _feed} = Feeds.delete_feed(feed)

    feeds = Feeds.list_feeds(%River{id: river_id})
    render_success(conn, "_listing.html", conn: conn, user: user, feeds: feeds)
  end
end
