defmodule Unsilo.Feeds.River do
  use Ecto.Schema
  import Ecto.Changeset

  alias Unsilo.Feeds.Feed
  alias Unsilo.Accounts.User

  schema "rivers" do
    field :name, :string
    field :sleep_time, :integer
    field(:access, AccessEnum)
    field :sort_order, :integer

    has_many(:feeds, Feed)
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(river, attrs) do
    river
    |> cast(attrs, [:name, :user_id])
    |> cast_access(attrs)
    |> validate_required([:name])
  end

  def cast_access(changeset, %{"access" => access}) do
    cast(changeset, %{"access" => String.to_integer(access)}, [:access])
  end

  def cast_access(changeset, _) do
    changeset
  end

  def sort_changeset(river, order) do
    cast(river, %{"sort_order" => order}, [:sort_order])
  end
end
