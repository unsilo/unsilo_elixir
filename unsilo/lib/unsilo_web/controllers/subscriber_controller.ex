defmodule UnsiloWeb.SubscriberController do
  use UnsiloWeb, :controller

  alias Unsilo.Domains
  alias Unsilo.Domains.Spot
  alias Unsilo.Domains.Subscriber

  plug :load_and_authorize_resource,
    model: Spot,
    id_name: "spot_id",
    persisted: true,
    only: [:delete]

  action_fallback UnsiloWeb.FallbackController

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

  def delete(%{assigns: %{authorized: false}}, _prms) do
    :err
  end

  def delete(conn = %{assigns: %{spot: %{id: spot_id}}}, %{"id" => subscriber_id}) do
    subscriber_id
    |> Domains.get_subscriber!()
    |> Domains.delete_subscriber()

    spot = Domains.get_spot!(spot_id)
    render_success(conn, "_listing.html", spot: spot)
  end
end
