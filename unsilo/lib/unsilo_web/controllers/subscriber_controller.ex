defmodule UnsiloWeb.SubscriberController do
  use UnsiloWeb, :controller

  alias Unsilo.Domains
  alias Unsilo.Domains.Subscriber

  def index(conn, _params) do
    subscriber = Domains.list_subscriber()
    render(conn, "index.html", subscriber: subscriber)
  end

  def new(conn, %{"spot_id" => spot_id}) do
    changeset = Domains.change_subscriber(%Subscriber{spot_id: spot_id})
    render_success(conn, "new.html", changeset: changeset, spot_id: spot_id)
  end

  def create(conn, %{"subscriber" => %{"spot_id" => spot_id} = subscriber_params}) do
    case Domains.create_subscriber(subscriber_params) do
      {:ok, _subscriber} ->
        render_success(conn, "thanks.html", [])

      {:error, %Ecto.Changeset{} = changeset} ->
        render_error(conn, "new.html", changeset: changeset, spot_id: spot_id)
    end
  end

  def delete(conn, %{"id" => id, "spot_id" => spot_id}) do
    subscriber = Domains.get_subscriber(id)
    {:ok, _subscribers} = Domains.delete_subscriber(subscriber)
    spot = Domains.get_spot!(spot_id)
    render_success(conn, "_listing.html", spot: spot)
  end
end
