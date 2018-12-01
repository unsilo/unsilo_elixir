defmodule UnsiloWeb.SpotController do
  use UnsiloWeb, :controller

  alias Unsilo.Domains
  alias Unsilo.Domains.Spot
  alias Plug.Conn

  plug :assign_sub_title

  plug :load_and_authorize_resource,
    model: Spot,
    preload: :subscribers,
    only: [:edit, :show, :update, :delete]

  action_fallback UnsiloWeb.FallbackController

  def assign_sub_title(conn, _) do
    conn
    |> Conn.assign(:page_sub_title, "spots")
    |> Conn.assign(:page_sub_title_url, Routes.spot_path(conn, :index))
    |> Conn.assign(:new_item_url, Routes.spot_path(conn, :new))
  end

  def action(%{assigns: %{authorized: false}}, _), do: :err

  def action(%{assigns: %{current_user: user, spot: spot}} = conn, _) do
    args = [conn, conn.params, user, spot]
    apply(__MODULE__, action_name(conn), args)
  end

  def action(%{assigns: %{current_user: user}} = conn, _) do
    args = [conn, conn.params, user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, user) do
    spots = Domains.list_spots_for_user(user)
    render(conn, "index.html", spots: spots, user: user)
  end

  def new(conn, _params, user) do
    changeset = Domains.change_spot(%Spot{user_id: user.id})
    render_success(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"spot" => spot_params}, user) do
    case Domains.create_spot(spot_params) do
      {:ok, _spot} ->
        spots = Domains.list_spots_for_user(user)
        render_success(conn, "_listing.html", conn: conn, user: user, spots: spots)

      {:error, %Ecto.Changeset{} = changeset} ->
        render_error(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _prms, _user, spot) do
    conn
    |> render("show.html", spot: spot)
  end

  def edit(conn, _prms, user, spot) do
    changeset = Domains.change_spot(spot)
    render_success(conn, "edit.html", user: user, spot: spot, changeset: changeset)
  end

  def update(conn, %{"spot" => spot_params}, user, spot) do
    case Domains.update_spot(spot, spot_params) do
      {:ok, _spot} ->
        render_success(conn, "_listing.html",
          conn: conn,
          user: user,
          spots: Domains.list_spots_for_user(user)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render_error(conn, "edit.html", spot: spot, changeset: changeset)
    end
  end

  def delete(conn, _, user, spot) do
    {:ok, _spot} = Domains.delete_spot(spot)

    spots = Domains.list_spots_for_user(user)
    render_success(conn, "_listing.html", conn: conn, user: user, spots: spots)
  end
end
