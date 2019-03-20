defmodule Unsilo.Feeds.Archive do
  use Ecto.Schema
  import Ecto.Changeset
  use Arc.Ecto.Schema

  schema "archives" do
    field :title, :string
    field :summary, :string
    field :url, :string
    field :author, :string
    field :subtitle, :string
    field :image, :string
    field :remote_id, :string
    field :categories, {:array, :string}
    field :archived_date, :utc_datetime

    field :artifact, Unsilo.Archive.Type
    timestamps()
  end

  @doc false
  def changeset(archive, attrs) do
    archive
    |> cast(attrs, [
      :title,
      :url,
      :summary,
      :author,
      :subtitle,
      :image,
      :remote_id,
      :image,
      :categories,
      :artifact
    ])
  end

  def image_changeset(archive, attrs) do
    archive
    |> cast_attachments(attrs, [:artifact])
  end
end
