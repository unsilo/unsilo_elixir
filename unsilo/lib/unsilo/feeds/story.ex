defmodule Unsilo.Feeds.Story do
  use Ecto.Schema
  import Ecto.Changeset

  alias Unsilo.Accounts.User
  alias Unsilo.Feeds.Feed
  alias Unsilo.Feeds.Archive
  alias FeederEx.Entry

  require Logger

  @date_formats [
    "%a, %e %b %Y %H:%M:%S %z",
    "%a, %e %b %Y %H:%M:%S %Z"
  ]

  schema "stories" do
    field :archived_at, :utc_datetime
    field :deleted_at, :utc_datetime
    field :read_at, :utc_datetime
    field :title, :string
    field :summary, :string
    field :url, :string
    field :author, :string
    field :subtitle, :string
    field :image, :string
    field :remote_id, :string
    field :categories, {:array, :string}, default: []
    field :updated, :utc_datetime

    belongs_to(:feed, Feed)
    belongs_to(:user, User)

    belongs_to(:archive, Archive)

    timestamps()
  end

  @doc false
  def changeset(story, attrs) do
    story
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
      :feed_id,
      :user_id,
      :archive_id,
      :deleted_at,
      :archived_at,
      :read_at
    ])
    |> cast_updated(attrs)
    |> validate_required([:user_id])
    |> unique_constraint(:remote_id, name: "stories_remote_id_url_index")
  end

  def params_from_entry(%Entry{
        author: author,
        title: title,
        subtitle: subtitle,
        updated: updated,
        summary: summary,
        link: link,
        image: image,
        id: id,
        categories: categories
      }) do
    %{
      author: author,
      title: title,
      subtitle: subtitle,
      updated: updated,
      summary: summary,
      url: link,
      image: image,
      remote_id: id,
      categories: categories
    }
  end

  defp cast_updated(changeset, %{updated: updated}) do
    new_date_time =
      case try_update_formats(updated, @date_formats) do
        {:ok, date_time} ->
          date_time

        {:error, _} ->
          Logger.error("Can't decode date format: #{inspect(updated)}")
          nil
      end

    cast(changeset, %{updated: new_date_time}, [:updated], [])
  end

  defp cast_updated(changeset, _), do: changeset

  defp try_update_formats(_date, []) do
    {:err, :unknown_format}
  end

  defp try_update_formats(%DateTime{} = date, _format_list) do
    {:ok, date}
  end

  defp try_update_formats(date, [first_format | rest]) do
    case Timex.parse(date, first_format, :strftime) do
      {:ok, %DateTime{} = date_time} ->
        {:ok, date_time}

      {:ok, naive_date_time} ->
        DateTime.from_naive(naive_date_time, "Etc/UTC")

      {:error, _} ->
        try_update_formats(date, rest)
    end
  end
end
