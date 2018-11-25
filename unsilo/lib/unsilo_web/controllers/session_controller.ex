defmodule UnsiloWeb.SessionController do
  use UnsiloWeb, :controller

  alias Ecto.Changeset
  alias Unsilo.Accounts
  alias Unsilo.Accounts.User

  def new(conn, _params) do
    conn
    |> render_success("new.html", changeset: %Changeset{data: %User{}})
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    with email <- String.downcase(email),
         {:ok, user} <- Accounts.user_from_email(email),
         true <- Bcrypt.verify_pass(password, user.password_hash) do
      conn
      |> UnsiloWeb.Auth.Guardian.Plug.sign_in(user)
      |> render_success
    else
      _ ->
        conn
        |> put_flash(:error, "Login Failed")
        |> render_error("new.html", changeset: %Changeset{data: %User{}})
    end
  end

  def delete(%{user: _user} = conn, _params) do
    conn
    |> UnsiloWeb.Auth.Guardian.Plug.sign_out()
    |> Map.delete(:user)
    |> render_success
  end
end
