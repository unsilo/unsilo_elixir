defmodule Unsilo.FeedsTest do
  use Unsilo.DataCase
  import Unsilo.Factory

  alias Unsilo.Feeds

  setup do
    user = insert(:user)
    admin_user = insert(:user, role: :admin)
    other_user = insert(:user)

    {:ok, [user: user, admin_user: admin_user, other_user: other_user]}
  end

  describe "rivers" do
    alias Unsilo.Feeds.River

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    setup(%{user: user} = context) do
      river = insert(:river, user_id: user.id)

      {:ok, Map.merge(context, %{river: river})}
    end

    test "list_rivers/0 returns all rivers", %{user: user, other_user: other_user} do
      assert Enum.count(Feeds.rivers_for_user(user)) == 1
      assert Enum.count(Feeds.rivers_for_user(other_user)) == 0
    end

    test "create_river/1 with valid data creates a river" do
      assert {:ok, %River{} = river} = Feeds.create_river(@valid_attrs)
      assert river.name == "some name"
    end

    test "create_river/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Feeds.create_river(@invalid_attrs)
    end

    test "update_river/2 can sort the river order", %{user: user, river: %River{id: river_1_id}} do
      %River{id: river_2_id} = insert(:river, user_id: user.id, sort_order: 2)
      %River{id: river_3_id} = insert(:river, user_id: user.id, sort_order: 3)

      {:ok, order_string} =
        Jason.encode(%{"river_tabs" => ["#{river_3_id}", "#{river_1_id}", "#{river_2_id}"]})

      Feeds.set_river_order(order_string)

      new_feeds =
        user
        |> Feeds.rivers_for_user()
        |> Enum.map(fn r -> r.id end)

      assert [^river_3_id, ^river_1_id, ^river_2_id] = new_feeds
    end

    test "update_river/2 with valid data updates the river", %{river: river} do
      assert {:ok, %River{} = river} = Feeds.update_river(river, @update_attrs)
      assert river.name == "some updated name"
    end

    test "update_river/2 with invalid data returns error changeset", %{river: river} do
      assert {:error, %Ecto.Changeset{}} = Feeds.update_river(river, @invalid_attrs)
    end

    test "delete_river/1 deletes the river", %{river: river} do
      assert {:ok, %River{}} = Feeds.delete_river(river)
      assert_raise Ecto.NoResultsError, fn -> Unsilo.Repo.get!(River, river.id) end
    end

    test "change_river/1 returns a river changeset", %{river: river} do
      assert %Ecto.Changeset{} = Feeds.change_river(river)
    end
  end

  describe "feeds" do
    alias Unsilo.Feeds.Feed

    @valid_attrs %{last_poll: ~N[2010-04-17 14:00:00], name: "some name", url: "some url"}
    @update_attrs %{
      name: "some updated name",
      url: "some updated url"
    }
    @invalid_attrs %{river_id: nil, user_id: nil}

    setup(%{user: user, other_user: other_user} = context) do
      river = insert(:river, user_id: user.id)
      feed = insert(:feed, user_id: user.id, river_id: river.id)

      other_river = insert(:river, user_id: other_user.id)
      other_feed = insert(:feed, user_id: other_user.id, river_id: other_river.id)

      {:ok, Map.merge(context, %{river: river, feed: feed, other_feed: other_feed})}
    end

    test "list_feeds/0 returns all feeds" do
      assert Enum.count(Feeds.list_feeds()) == 2
    end

    test "list_feeds/1 returns all feeds for a river", %{river: river, feed: feed} do
      assert Feeds.list_feeds(river) == [feed]
    end

    test "create_feed/1 with valid data creates a feed", %{user: user, river: river} do
      {:ok, %Feed{} = feed} =
        @valid_attrs
        |> Map.merge(%{user_id: user.id, river_id: river.id})
        |> Feeds.create_feed()

      assert feed.name == "some name"
      assert feed.url == "some url"
    end

    test "create_feed/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Feeds.create_feed(@invalid_attrs)
    end

    test "update_feed/2 with valid data updates the feed", %{feed: feed} do
      assert {:ok, %Feed{} = feed} = Feeds.update_feed(feed, @update_attrs)
      assert feed.name == "some updated name"
      assert feed.url == "some updated url"
    end

    test "update_feed/2 with invalid data returns error changeset", %{feed: feed} do
      assert {:error, %Ecto.Changeset{}} = Feeds.update_feed(feed, @invalid_attrs)
      assert feed == Unsilo.Repo.get!(Feed, feed.id)
    end

    test "delete_feed/1 deletes the feed", %{feed: feed} do
      assert {:ok, %Feed{}} = Feeds.delete_feed(feed)
      assert_raise Ecto.NoResultsError, fn -> Unsilo.Repo.get!(Feed, feed.id) end
    end

    test "change_feed/1 returns a feed changeset", %{feed: feed} do
      assert %Ecto.Changeset{} = Feeds.change_feed(feed)
    end
  end

  describe "stories" do
    alias Unsilo.Feeds.Story

    @valid_attrs %{
      title: "some name",
      read_at: ~N[2010-04-17 14:00:00],
      summary: "some summary",
      url: "some url"
    }
    @update_attrs %{
      title: "some updated name",
      read_at: ~N[2011-05-18 15:01:01],
      summary: "some updated summary",
      url: "some updated url"
    }
    @invalid_attrs %{
      user_id: nil
    }
    setup(%{user: user} = context) do
      river = insert(:river, user_id: user.id)
      feed = insert(:feed, user_id: user.id, river_id: river.id)
      story = insert(:story, user_id: user.id, feed_id: feed.id)

      {:ok, Map.merge(context, %{river: river, feed: feed, story: story})}
    end

    test "list_stories/1 returns all stories", %{user: user, other_user: other_user, story: story} do
      _other_story = insert(:story, user_id: other_user.id)

      [a_story] = Feeds.list_stories(user)

      assert a_story.id == story.id
    end

    test "list_stories/2 returns all stories with state", %{user: user, feed: feed} do
      archived_story =
        insert(:story, user_id: user.id, feed_id: feed.id, archived_at: ~N[2011-05-18 15:01:01])

      read_story =
        insert(:story, user_id: user.id, feed_id: feed.id, read_at: ~N[2011-05-18 15:01:01])

      deleted_story =
        insert(:story, user_id: user.id, feed_id: feed.id, deleted_at: ~N[2011-05-18 15:01:01])

      [%Story{id: test_story_id}] = Feeds.list_stories("archived", user)
      assert test_story_id == archived_story.id
      [%Story{id: test_story_id}] = Feeds.list_stories("read", user)
      assert test_story_id == read_story.id
      [%Story{id: test_story_id}] = Feeds.list_stories("deleted", user)
      assert test_story_id == deleted_story.id
    end

    test "cull_deleted_stories/2 remoges deleted storiev", %{user: user, feed: feed} do
      now_time = DateTime.utc_now()

      for offset <- [-3, -4, -5, -6] do
        insert(:story,
          user_id: user.id,
          feed_id: feed.id,
          deleted_at: Timex.shift(now_time, days: offset)
        )
      end

      Feeds.cull_deleted_stories(4)
      story_list = Feeds.list_stories(user)

      assert Enum.count(story_list) == 3
    end

    test "create_story/1 with valid data creates a story", %{user: user, feed: feed} do
      valid_attrs = Map.merge(@valid_attrs, %{user_id: user.id})
      assert {:ok, %Story{} = story} = Feeds.create_story_if_recent(valid_attrs, feed)
      assert story.title == "some name"
      assert story.summary == "some summary"
      assert story.url == "some url"
    end

    test "create_story/1 with invalid data returns error changeset", %{feed: feed} do
      feed = %{feed | user_id: nil}
      assert {:error, %Ecto.Changeset{}} = Feeds.create_story_if_recent(@invalid_attrs, feed)
    end

    test "update_story/2 with valid data updates the story", %{story: story} do
      assert {:ok, %Story{} = story} = Feeds.update_story(story, @update_attrs)
      assert story.title == "some updated name"
      assert story.url == "some updated url"
    end

    test "update_story/2 with invalid data returns error changeset", %{story: story} do
      assert {:error, %Ecto.Changeset{}} = Feeds.update_story(story, @invalid_attrs)
      assert story == Unsilo.Repo.get!(Story, story.id)
    end
  end

  describe "archives" do
    alias Unsilo.Feeds.Archive

    @valid_attrs %{title: "some name", url: "some url"}

    test "create_archive/1 with valid data creates a archive" do
      assert {:ok, %Archive{} = archive} = Feeds.create_archive(@valid_attrs)
      assert archive.title == "some name"
      assert archive.url == "some url"
    end
  end
end
