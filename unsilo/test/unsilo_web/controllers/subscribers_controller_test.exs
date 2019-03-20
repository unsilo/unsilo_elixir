defmodule UnsiloWeb.SubscriberControllerTest do
  use UnsiloWeb.ConnCase

  import Unsilo.Factory

  @create_attrs %{email: "some email", spot_id: 42}
  @invalid_attrs %{email: nil, spot_id: 27}

  setup do
    user = insert(:user)
    admin_user = insert(:user, role: :admin)
    other_user = insert(:user)
    spot = insert(:spot, user_id: user.id)
    subscriber = insert(:subscriber, spot_id: spot.id)

    conn = Phoenix.ConnTest.build_conn()

    {:ok,
     [
       conn: conn,
       admin_user: admin_user,
       user: user,
       other_user: other_user,
       spot: spot,
       subscriber: subscriber
     ]}
  end

  describe "new subscriber" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.subscriber_path(conn, :new, spot_id: 1))

      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "Enter your email address"
    end
  end

  describe "create subscriber" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.subscriber_path(conn, :create), subscriber: @create_attrs)

      assert %{"status" => "ok", "html" => html} = json_response(conn, 200)
      assert html =~ "Thanks for subscribing!"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.subscriber_path(conn, :create), subscriber: @invalid_attrs)

      assert %{"status" => "err", "html" => html} = json_response(conn, 200)
      assert html =~ "Enter your email address"
    end
  end

  describe "delete subscriber" do
    setup [:login_user]

    test "deletes chosen subscriber", %{conn: conn, subscriber: %{spot_id: spot_id} = subscriber} do
      conn = delete(conn, Routes.subscriber_path(conn, :delete, subscriber, spot_id: spot_id))
      assert json_response(conn, 200) == %{"html" => "", "status" => "ok"}
    end

    test "can't delete a subscriber from a different user", %{conn: conn, other_user: other_user} do
      other_spot = insert(:spot, user_id: other_user.id)
      other_subscriber = insert(:subscriber, spot_id: other_spot.id)

      conn =
        delete(
          conn,
          Routes.subscriber_path(conn, :delete, other_subscriber, spot_id: other_spot.id)
        )

      assert json_response(conn, 200) == %{"html" => "unauthorized", "status" => "err"}
    end
  end

  describe "admin has power over all" do
    setup [:login_admin]

    test "can delete someone elses spot", %{conn: conn, other_user: other_user} do
      other_spot = insert(:spot, user_id: other_user.id)
      other_subscriber = insert(:subscriber, spot_id: other_spot.id)

      conn =
        delete(
          conn,
          Routes.subscriber_path(conn, :delete, other_subscriber, spot_id: other_spot.id)
        )

      assert %{"status" => "ok", "html" => ""} = json_response(conn, 200)
    end
  end

  defp login_admin(%{conn: conn, admin_user: admin_user} = ctxt) do
    conn = UnsiloWeb.Auth.Guardian.Plug.sign_in(conn, admin_user)

    {:ok, Map.merge(ctxt, %{conn: conn})}
  end
end
