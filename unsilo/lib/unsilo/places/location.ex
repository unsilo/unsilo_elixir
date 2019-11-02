defmodule Unsilo.Places.Location do
  use Ecto.Schema
  import Ecto.Changeset

  alias Unsilo.Accounts.User

  schema "locations" do
    field :address, :string
    field :lat, :float
    field :lng, :float
    field :name, :string
    field :phone, :string
    field :type, LocationEnum, default: 0
    field(:access, AccessEnum)

    field :sort_order, :integer, default: 0
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    IO.inspect(attrs, label: "attrs")
    location
    |> cast(attrs, [:name, :lat, :lng, :address, :phone])
    |> cast_access(attrs)
    |> cast_type(attrs)
    |> validate_required([:name, :type])
    |> IO.inspect
  end

  def cast_access(changeset, %{"access" => access}) do
    cast(changeset, %{"access" => String.to_integer(access)}, [:access])
  end

  def cast_access(changeset, _) do
    changeset
  end

  def cast_type(changeset, %{"type" => type}) do
    cast(changeset, %{"type" => String.to_integer(type)}, [:type])
  end

  def cast_type(changeset, _) do
    changeset
  end
end
