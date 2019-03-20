defmodule UnsiloWeb.StoryControllerTest do
  use UnsiloWeb.ConnCase

  alias Unsilo.Feeds.Story

  import Unsilo.Factory

  setup do
    user = insert(:user)
    admin_user = insert(:user, role: :admin)
    other_user = insert(:user)
    river = insert(:river, user_id: user.id)
    feed = insert(:feed, user_id: user.id, river_id: river.id)

    story = insert(:story, user_id: user.id, feed_id: feed.id)

    arc_story =
      insert(:story, user_id: user.id, feed_id: feed.id, archived_at: DateTime.utc_now())

    del_story = insert(:story, user_id: user.id, feed_id: feed.id, deleted_at: DateTime.utc_now())

    read_story = insert(:story, user_id: user.id, feed_id: feed.id, read_at: DateTime.utc_now())

    conn = Phoenix.ConnTest.build_conn()

    {:ok,
     [
       conn: conn,
       admin_user: admin_user,
       user: user,
       other_user: other_user,
       river: river,
       feed: feed,
       story: story,
       archived_story: arc_story,
       deleted_story: del_story,
       read_story: read_story
     ]}
  end

  describe "index" do
    setup [:login_user]

    test "lists archived stories", %{conn: conn, archived_story: archived_story} do
      conn = get(conn, Routes.story_path(conn, :index, %{mode: "archived"}))
      assert html_response(conn, 200) =~ archived_story.title
    end

    test "index shows edit buttons", %{conn: conn} do
      conn = get(conn, Routes.story_path(conn, :index, %{mode: "archived"}))
      dats = html_response(conn, 200)

      assert dats =~ "mark_delete"
    end

    test "lists read stories", %{conn: conn, read_story: read_story} do
      conn = get(conn, Routes.story_path(conn, :index, %{mode: "read"}))
      assert html_response(conn, 200) =~ read_story.title
    end

    test "lists deleted stories", %{conn: conn, deleted_story: deleted_story} do
      conn = get(conn, Routes.story_path(conn, :index, %{mode: "deleted"}))
      assert html_response(conn, 200) =~ deleted_story.title
    end
  end

  describe "update - mark story read" do
    setup [:login_user]

    test "redirects when data is valid", %{conn: conn, story: story} do
      assert story.read_at == nil

      put(conn, Routes.story_path(conn, :update, story), %{"cmd" => "mark_read"})
      new_story = Unsilo.Repo.get(Story, story.id)

      assert new_story.read_at != nil
    end
  end

  describe "update - delete story" do
    setup [:login_user]

    test "redirects when data is valid", %{conn: conn, story: story} do
      assert story.deleted_at == nil

      put(conn, Routes.story_path(conn, :update, story), %{"cmd" => "mark_delete"})
      new_story = Unsilo.Repo.get(Story, story.id)

      assert new_story.deleted_at != nil
    end
  end
end
