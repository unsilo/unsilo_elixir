defmodule Unsilo.Domains.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false


  schema "subscribers" do
    field :email, :string
    field :spot_id, :integer

    timestamps()
  end

  @doc false
  def changeset(subscribers, attrs) do
    subscribers
    |> cast(attrs, [:email, :spot_id])
    |> validate_required([:email, :spot_id])
  end
end
