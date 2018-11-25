defmodule Unsilo.Accounts do
  import Ecto.Query, warn: false

  alias Unsilo.Accounts.User
  alias Unsilo.Repo

  def create_user_changeset(params) do
    User.changeset(%User{}, params)
  end

  def user_changeset(user, params) do
    User.changeset(user, params)
  end

  def create_user(params) do
    User.changeset(%User{}, params)
    |> Repo.insert()
  end

  def change_user(%User{} = user, params \\ %{}) do
    User.changeset(user, params)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def user_from_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:err, :not_found}
      user -> {:ok, user}
    end
  end

  def user_from_id(user_id) do
    case Repo.get(User, user_id) do
      nil -> {:err, :not_found}
      user -> {:ok, user}
    end
  end
end
