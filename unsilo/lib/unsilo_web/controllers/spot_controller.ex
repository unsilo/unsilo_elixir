defmodule UnsiloWeb.SpotController do
  use UnsiloWeb, :controller

  alias Unsilo.Domains
  alias Unsilo.Domains.Spot
  alias Plug.Conn

  plug :assign_sub_title

  def assign_sub_title(conn, _) do
    conn
    |> Conn.assign(:page_sub_title, "spots")
    |> Conn.assign(:page_sub_title_url, Routes.spot_path(conn, :index))
    |> Conn.assign(:new_item_url, Routes.spot_path(conn, :new))
  end

  def index(%{user: user} = conn, _params) do
    spots = Domains.list_spots_for_user(user)
    render(conn, "index.html", spots: spots, user: user)
  end

  def new(conn, _params) do
    changeset = Domains.change_spot(%Spot{})
    render_success(conn, "new.html", changeset: changeset)
  end

  def create(%{user: user} = conn, %{"spot" => spot_params}) do
    case Domains.create_spot(spot_params) do
      {:ok, _spot} ->
        spots = Domains.list_spots_for_user(user)
        render_success(conn, "_listing.html", conn: conn, user: user, spots: spots)

      {:error, %Ecto.Changeset{} = changeset} ->
        render_error(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    spot = Domains.get_spot!(id)
    conn
    |> render("show.html", spot: spot)
  end

  def edit(%{user: user} = conn, %{"id" => id}) do
    spot = Domains.get_spot!(id)
    changeset = Domains.change_spot(spot)
    render_success(conn, "edit.html", user: user, spot: spot, changeset: changeset)
  end

  def update(%{user: user} = conn, %{"id" => id, "spot" => spot_params}) do
    spot = Domains.get_spot!(id)

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

  def delete(%{user: user} = conn, %{"id" => id}) do
    spot = Domains.get_spot!(id)
    {:ok, _spot} = Domains.delete_spot(spot)

    spots = Domains.list_spots_for_user(user)
    render_success(conn, "_listing.html", conn: conn, user: user, spots: spots)
  end
end
