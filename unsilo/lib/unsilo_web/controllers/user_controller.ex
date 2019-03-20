defmodule UnsiloWeb.UserController do
  use UnsiloWeb, :controller

  alias Unsilo.Accounts
  alias Unsilo.Accounts.User
  import Canada.Can, only: [can?: 3]

  action_fallback UnsiloWeb.FallbackController

  plug :load_and_authorize_resource, model: User, only: [:edit, :show, :update, :delete]

  def action(%{assigns: %{authorized: false}}, _), do: :err

  use UnsiloWeb.AssignableController, assignable: :user

  def new(conn, _params, current_user \\ %User{}) do
    if can?(current_user, :new, User) do
      changeset = Accounts.create_user_changeset(%{})
      render_success(conn, "new.html", changeset: changeset)
    else
      render_error(conn)
    end
  end

  def create(conn, %{"user" => user_params}, current_user \\ %User{}) do
    if can?(current_user, :create, User) && permit_uninvited_signups?() do
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
    else
      render_error(conn)
    end
  end

  def update(conn, %{"user" => user_params}, _current_user, user) do
    with {:ok, _user} <- Accounts.change_user(user, user_params) do
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

  def edit(conn, _prms, _current_user, user) do
    changeset = Accounts.user_changeset(user, %{})
    render_success(conn, "edit.html", changeset: changeset, user: user)
  end

  def show(conn, _prms, _current_user, user) do
    render(conn, "show.html", user: user)
  end

  def delete(conn, _prms, _current_user, user) do
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> render_success()
  end

  def permit_uninvited_signups? do
    Application.get_env(:unsilo, Unsilo.UserController)[:allow_signups]
  end
end
