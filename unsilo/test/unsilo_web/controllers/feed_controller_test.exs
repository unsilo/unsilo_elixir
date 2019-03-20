defmodule UnsiloWeb.FeedControllerTest do
  import Unsilo.Factory

  use UnsiloWeb.ConnCase

  @create_attrs %{last_poll: ~N[2010-04-17 14:00:00], name: "some name", url: "some url"}
  @invalid_attrs %{river_id: nil}

  setup do
    user = insert(:user)
    admin_user = insert(:user, role: :admin)
    other_user = insert(:user)
    river = insert(:river, user_id: user.id)
    feed = insert(:feed, user_id: user.id, river_id: river.id)

    conn = Phoenix.ConnTest.build_conn()

    {:ok,
     [
       conn: conn,
       admin_user: admin_user,
       user: user,
       other_user: other_user,
       river: river,
       feed: feed
     ]}
  end

  describe "new feed" do
    setup [:login_user]

    test "renders form", %{conn: conn, river: river} do
      conn = get(conn, Routes.feed_path(conn, :new, river_id: river.id))

      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "New Feed"
    end
  end

  describe "create feed" do
    setup [:login_user]

    test "redirects to show when data is valid", %{conn: conn, river: river} do
      conn =
        post(conn, Routes.feed_path(conn, :create),
          feed: Map.merge(%{river_id: river.id}, @create_attrs)
        )

      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, river: river} do
      conn =
        post(conn, Routes.feed_path(conn, :create),
          feed: Map.merge(%{river_id: river.id}, @invalid_attrs)
        )

      assert %{"status" => "err", "html" => html} = json_response(conn, 200)
    end
  end

  describe "delete feed" do
    setup [:login_user]

    test "deletes chosen feed", %{conn: conn, feed: feed} do
      conn = delete(conn, Routes.feed_path(conn, :delete, feed))
      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
    end
  end
end
