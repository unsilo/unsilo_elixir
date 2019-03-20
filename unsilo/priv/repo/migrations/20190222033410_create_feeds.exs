defmodule Unsilo.Repo.Migrations.CreateFeeds do
  use Ecto.Migration

  def change do
    create table(:rivers) do
      add :name, :string
      add :user_id, :integer
      add :sleep_time, :integer
      add :access, :integer, default: 0
      add :sort_order, :integer, default: 0

      timestamps()
    end

    create table(:feeds) do
      add :river_id, :integer
      add :user_id, :integer

      add :name, :string
      add :url, :string
      add :last_poll, :utc_datetime
      add :sleep_time, :integer

      timestamps()
    end

    create table(:stories) do
      add :feed_id, :integer
      add :user_id, :integer
      add :archive_id, :integer

      add :url, :string
      add :summary, :binary

      add :author, :string
      add :title, :string
      add :subtitle, :string
      add :image, :string
      add :remote_id, :string
      add :categories, {:array, :string}, default: []

      add :updated, :utc_datetime
      add :archived_at, :utc_datetime
      add :deleted_at, :utc_datetime
      add :read_at, :utc_datetime

      timestamps()
    end

    create table(:archives) do
      add :archived_date, :utc_datetime

      add :url, :string
      add :summary, :binary

      add :author, :string
      add :title, :string
      add :subtitle, :string
      add :image, :string
      add :remote_id, :string
      add :categories, {:array, :string}, default: []

      add :artifact, :string
      timestamps()
    end

    create index("stories", [:remote_id, :url], unique: true)
  end
end
