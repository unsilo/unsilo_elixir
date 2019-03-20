defmodule Unsilo.Feeds.Feed do
  use Ecto.Schema
  import Ecto.Changeset

  alias Unsilo.Accounts.User
  alias Unsilo.Feeds.River
  alias Unsilo.Feeds.Story

  schema "feeds" do
    field :last_poll, :utc_datetime
    field :name, :string
    field :url, :string
    field :sleep_time, :integer

    has_many(:stories, Story)

    belongs_to(:river, River)
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:name, :url, :last_poll, :river_id, :user_id])
    |> validate_required([:river_id, :user_id])
  end
end
