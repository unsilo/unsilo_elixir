defmodule UnsiloWeb.UserController do
  use UnsiloWeb, :controller

  alias Unsilo.Accounts
  alias Unsilo.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.create_user_changeset(%{})
    render_success(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, %User{} = user} ->
        conn
        |> UnsiloWeb.Auth.Guardian.Plug.sign_in(user)
        |> render_success()

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Sign up Failed")
        |> render_error("new.html", changeset: changeset, layout: false)
    end
  end


  def update(conn, %{"id" => id, "user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.user_from_id(id),
         {:ok, _user} <- Accounts.change_user(user, user_params) do
      conn
      |> render_success()

    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "update Failed")
        |> render_error("edit.html", changeset: changeset, user: changeset.data)
        
      _ ->
        render_error(conn)
    end
  end

  def edit(conn, %{"id" => id}) do
    {:ok, user} = Accounts.user_from_id(id)

    changeset = Accounts.user_changeset(user, %{})
    render_success(conn, "edit.html", changeset: changeset, user: user)
  end

  def show(conn, %{"id" => id}) do
    case Accounts.user_from_id(id) do
      {:ok, user} -> 
        render(conn, "show.html", user: user)
      _ ->
        render(conn, "404.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    {:ok, user} = Accounts.user_from_id(id)
    {:ok, _user} = Accounts.delete_user(user)
    conn
    |> put_flash(:info, "User deleted successfully.")
    |> render_success()
  end
end
