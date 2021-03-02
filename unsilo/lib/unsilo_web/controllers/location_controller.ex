defmodule UnsiloWeb.LocationController do
  use UnsiloWeb, :controller

  alias Unsilo.Accounts.User
  alias Unsilo.Places
  alias Unsilo.Places.Location
  alias Plug.Conn

  plug :assign_sub_title

  plug :load_and_authorize_resource,
    model: Location,
    only: [:edit, :update, :delete]

  action_fallback UnsiloWeb.FallbackController

  use UnsiloWeb.AssignableController, assignable: :location

  def assign_sub_title(conn, _) do
    conn
    |> Conn.assign(:page_sub_title, "locations")
    |> Conn.assign(:page_sub_title_url, Routes.location_path(conn, :index))
    |> Conn.assign(:new_item_url, Routes.location_path(conn, :new))
  end

  def index(conn, _params, user \\ %User{}) do
    locations = Places.list_locations()
    render(conn, "index.html", user: user, locations: locations)
  end

  def new(conn, _params, _user) do
    changeset = Places.change_location(%Location{})
    render_success(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"location" => location_params}, user) do
    case Places.create_location(location_params) do
      {:ok, _location} ->
        locations = Places.list_locations()
        render_success(conn, "_listing.html", conn: conn, user: user, locations: locations)

      {:error, %Ecto.Changeset{} = changeset} ->
        render_error(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user \\ %User{}) do
    location = Places.get_location!(id, user)
    render(conn, "show.html", user: user, location: location)
  end

  def edit(conn, %{"id" => id}, user) do
    location = Places.get_location!(id, user)

    location = %{
      location
      | access: AccessEnum.__enum_map__()[location.access],
        type: LocationEnum.__enum_map__()[location.type]
    }

    changeset = Places.change_location(location)
    render_success(conn, "edit.html", user: user, location: location, changeset: changeset)
  end

  def update(conn, %{"id" => id, "location" => location_params}, user) do
    location = Places.get_location!(id, user)

    case Places.update_location(location, location_params) do
      {:ok, _location} ->
        render_success(conn, "_listing.html",
          conn: conn,
          user: user,
          locations: Places.list_locations()
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render_error(conn, "edit.html", location: location, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    location = Places.get_location!(id, user)
    {:ok, _location} = Places.delete_location(location)

    locations = Places.list_locations()
    render_success(conn, "_listing.html", conn: conn, user: user, locations: locations)
  end
end
