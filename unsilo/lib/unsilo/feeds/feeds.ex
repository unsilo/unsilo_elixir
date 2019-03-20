defmodule Unsilo.Feeds do
  @moduledoc """
  The Feeds context.
  """

  import Ecto.Query, warn: false
  alias Unsilo.Repo
  alias Ecto.Changeset

  alias Unsilo.Accounts.User
  alias Unsilo.Feeds.Story
  alias Unsilo.Feeds.Feed
  alias Unsilo.Feeds.River
  alias Unsilo.Feeds.Archive

  require Logger

  def rivers_for_user(%User{id: nil}) do
    qry =
      from r in River,
        where: r.access == ^:public,
        order_by: [asc: r.sort_order, asc: r.id],
        preload: [:feeds]

    Repo.all(qry)
    |> IO.inspect()
  end

  def rivers_for_user(%User{id: user_id}) do
    qry =
      from r in River,
        where: r.user_id == ^user_id,
        order_by: [asc: r.sort_order, asc: r.id],
        preload: [:feeds]

    Repo.all(qry)
  end

  def set_river_order(river_id_list) do
    {:ok, %{"river_tabs" => tab_order}} = Jason.decode(river_id_list)

    tab_order
    |> Enum.with_index()
    |> Enum.map(fn {s, i} ->
      IO.inspect({s, i})

      River.sort_changeset(%River{id: String.to_integer(s)}, i + 1)
      |> Repo.update()
    end)
  end

  def create_river(attrs \\ %{}) do
    %River{}
    |> River.changeset(attrs)
    |> Repo.insert()
  end

  def get_river(id) do
    qry =
      from r in River,
        where: r.id == ^id,
        preload: [:feeds]

    Repo.one(qry)
  end

  def update_river(%River{} = river, attrs) do
    river
    |> River.changeset(attrs)
    |> Repo.update()
  end

  def delete_river(%River{} = river) do
    Repo.delete(river)
  end

  def change_river(%River{} = river) do
    River.changeset(river, %{})
  end

  alias Unsilo.Feeds.Feed

  def list_feeds do
    Repo.all(Feed)
  end

  def list_feeds(%River{id: river_id}) do
    qry =
      from f in Feed,
        where: f.river_id == ^river_id

    Repo.all(qry)
  end

  def set_last_poll(feed) do
    update_feed(feed, %{last_poll: DateTime.utc_now()})
  end

  def create_feed(attrs \\ %{}) do
    %Feed{}
    |> Feed.changeset(attrs)
    |> Repo.insert()
  end

  def update_feed(%Feed{} = feed, attrs) do
    feed
    |> Feed.changeset(attrs)
    |> Repo.update()
  end

  def delete_feed(%Feed{} = feed) do
    Repo.delete(feed)
  end

  def change_feed(%Feed{} = feed) do
    Feed.changeset(feed, %{})
  end

  alias Unsilo.Feeds.Story

  def cull_deleted_stories(deletion_retention) do
    qry =
      from s in Story,
        where: s.deleted_at < ago(^deletion_retention, "day")

    Repo.delete_all(qry)
  end

  def readable_stories(%River{id: river_id}) do
    qry =
      from s in Story,
        join: f in Feed,
        where: f.river_id == ^river_id,
        where: s.feed_id == f.id,
        where: is_nil(s.deleted_at),
        where: is_nil(s.archived_at),
        where: is_nil(s.read_at),
        preload: [:archive]

    Repo.all(qry)
  end

  def stories_for_feed(%Feed{stories: stories}) do
    stories
  end

  def create_story_if_recent(params, %Feed{id: feed_id, last_poll: last_poll, user_id: user_id}) do
    full_params = Map.merge(params, %{feed_id: feed_id, user_id: user_id})

    story =
      %Story{}
      |> Story.changeset(full_params)

    test_time = Changeset.get_change(story, :updated, Timex.zero())

    if Timex.after?(test_time, last_poll) do
      Repo.insert(story)
    else
      {:err, :outdated}
    end
  end

  def list_stories(%User{} = user) do
    base_query()
    |> is_owned(user)
    |> Repo.all()
  end

  def list_stories("archived", %User{} = user) do
    base_query()
    |> archived()
    |> is_owned(user)
    |> Repo.all()
  end

  def list_stories("read", %User{} = user) do
    base_query()
    |> read()
    |> is_owned(user)
    |> Repo.all()
  end

  def list_stories("deleted", %User{} = user) do
    base_query()
    |> deleted()
    |> is_owned(user)
    |> Repo.all()
  end

  def base_query() do
    from s in Story, preload: [:archive]
  end

  def archived(qry) do
    qry |> where([s], not is_nil(s.archived_at))
  end

  def read(qry) do
    qry |> where([s], not is_nil(s.read_at))
  end

  def deleted(qry) do
    qry |> where([s], not is_nil(s.deleted_at))
  end

  def is_owned(qry, %User{id: user_id}) do
    qry |> where([s], s.user_id == ^user_id)
  end

  def update_story(%Story{} = story, attrs) do
    story
    |> Story.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Creates a archive.

  ## Examples

      iex> create_archive(%{field: value})
      {:ok, %Archive{}}

      iex> create_archive(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_archive(attrs \\ %{})

  def create_archive(%Story{url: story_url} = story) do
    arch_params =
      story
      |> Map.from_struct()
      |> Map.take([
        :title,
        :url,
        :summary,
        :author,
        :subtitle,
        :image,
        :remote_id,
        :image,
        :categories
      ])

    with {:ok, %HTTPoison.Response{body: body}} <-
           HTTPoison.get(story_url, [], follow_redirect: true),
         {:ok, filename} <-
           PdfGenerator.generate(body,
             shell_params: [
               "--load-error-handling",
               "ignore",
               "--disable-javascript",
               "--print-media-type",
               "--no-images"
             ],
             page_size: "A5",
             delete_temporary: true
           ),
         {:ok, archive} = create_archive(arch_params) do
      qrti = %Plug.Upload{content_type: "image/pdf", filename: "archive.pdf", path: filename}

      archive
      |> Archive.image_changeset(%{artifact: qrti})
      |> Repo.update()

      story
      |> Story.changeset(%{archived_at: DateTime.utc_now(), archive_id: archive.id})
      |> Repo.update()
    else
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("pdf fetch failed")
        Logger.error(reason)

      {:error, reason} ->
        Logger.error("pdf generation failed")
        Logger.error(reason)
    end

    story
  end

  def create_archive(attrs) do
    %Archive{}
    |> Archive.changeset(attrs)
    |> Repo.insert()
  end
end
