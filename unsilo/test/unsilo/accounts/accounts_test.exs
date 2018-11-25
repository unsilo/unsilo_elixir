defmodule Unsilo.AccountsTest do
  use Unsilo.DataCase

  alias Unsilo.Accounts

  describe "users" do
    alias Unsilo.Accounts.User

    @valid_attrs %{password: "some encrypted_password", email: "some email"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
    end
  end
end
