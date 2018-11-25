defmodule UnsiloWeb.SubscriberControllerTest do
  use UnsiloWeb.ConnCase

  alias Unsilo.Domains

  @create_attrs %{email: "some email", spot_id: 42}
  @invalid_attrs %{email: nil, spot_id: 27}
  @create_spot_attrs %{
    domains: "some updated domain",
    user_id: 1
  }

  def fixture(:subscriber) do
    {:ok, spot} = Domains.create_spot(@create_spot_attrs)
    {:ok, subscriber} = Domains.create_subscriber(%{@create_attrs | spot_id: spot.id})
    subscriber
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
    setup [:create_subscriber]

    test "deletes chosen subscriber", %{conn: conn, subscriber: %{spot_id: spot_id} = subscriber} do
      conn = delete(conn, Routes.subscriber_path(conn, :delete, subscriber, spot_id: spot_id))
      assert json_response(conn, 200) == %{"html" => "", "status" => "ok"}
    end
  end

  defp create_subscriber(_) do
    subscriber = fixture(:subscriber)
    {:ok, subscriber: subscriber}
  end
end
