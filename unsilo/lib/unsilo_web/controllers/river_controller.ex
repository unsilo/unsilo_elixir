defmodule UnsiloWeb.RiverController do
  use UnsiloWeb, :controller

  alias Unsilo.Accounts.User
  alias Unsilo.Feeds
  alias Unsilo.Feeds.River
  alias Plug.Conn

  plug :assign_sub_title

  plug :load_and_authorize_resource,
    model: River,
    preload: :feeds,
    only: [:edit, :update, :delete]

  action_fallback UnsiloWeb.FallbackController

  use UnsiloWeb.AssignableController, assignable: :river

  def assign_sub_title(conn, _) do
    conn
    |> Conn.assign(:page_sub_title, "rivers")
    |> Conn.assign(:page_sub_title_url, Routes.river_path(conn, :index))
    |> Conn.assign(:new_item_url, Routes.river_path(conn, :new))
  end

  def index(conn, _params, user \\ %User{}) do
    rivers = Feeds.rivers_for_user(user)
    render(conn, "index.html", user: user || %User{}, rivers: rivers)
  end

  def new(conn, _params, %User{id: user_id}) do
    changeset = Feeds.change_river(%River{user_id: user_id})
    render_success(conn, "new.html", changeset: changeset)
  end

  def show(conn, %{"id" => id}, user) do
    case Unsilo.Feeds.get_river(id) do
      nil ->
        :err

      river ->
        conn
        |> render_success("_feeds.html",
          river: river,
          user: user,
          stories: Unsilo.Feeds.readable_stories(river)
        )
    end
  end

  def create(conn, %{"river" => river_params}, %User{id: user_id} = user) do
    river_params
    |> Map.put("user_id", user_id)
    |> Feeds.create_river()
    |> case do
      {:ok, _river} ->
        rivers = Feeds.rivers_for_user(user)
        render_success(conn, "_listing.html", conn: conn, user: user, rivers: rivers)

      {:error, %Ecto.Changeset{} = changeset} ->
        render_error(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _prms, _user, river) do
    changeset = Feeds.change_river(%{river | access: AccessEnum.__enum_map__()[river.access]})

    render(conn, "edit.html", river: river, changeset: changeset)
  end

  def update(conn, %{"sort_change" => sort_data}, _user, _river) do
    Feeds.set_river_order(sort_data)
    text(conn, "ok")
  end

  def update(conn, %{"cmd" => story_cmd}, user, river) do
    case story_cmd do
      "mark_update" ->
        Unsilo.Feeds.Heartbeat.force_beat(river)

        render_success(conn, "_feeds.html",
          river: river,
          user: user,
          stories: Unsilo.Feeds.readable_stories(river)
        )
    end
  end

  def update(conn, %{"river" => river_params}, _user, river) do
    case Feeds.update_river(river, river_params) do
      {:ok, _river} ->
        conn
        |> put_flash(:info, "River updated successfully.")
        |> redirect(to: Routes.river_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", river: river, changeset: changeset)
    end
  end

  def delete(conn, _prms, user, river) do
    {:ok, _river} = Feeds.delete_river(river)

    rivers = Feeds.rivers_for_user(user)
    render_success(conn, "_listing.html", conn: conn, user: user, rivers: rivers)
  end
end
