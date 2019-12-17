defmodule Unsilo.Places.Device do
  use Ecto.Schema
  import Ecto.Changeset

  alias Unsilo.Places.Location

  schema "devices" do
    field :app_key, :string
    field :name, :string
    field :sort_order, :integer
    field :status, :string
    field :unsilo_uuid, :string
    field :ip_address, :string
    field :uuid, :string
    field :type, :string

    belongs_to(:location, Location)

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [
      :name,
      :type,
      :unsilo_uuid,
      :uuid,
      :sort_order,
      :app_key,
      :ip_address,
      :status,
      :location_id
    ])
    |> validate_required([:name, :type])
  end
end
