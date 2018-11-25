defmodule Unsilo.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.UUID

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:role, :integer)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:password_hash, :string)
    field(:password_reset_token, UUID)
    field(:password_reset_token_expires, :utc_datetime)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :name])
    |> unique_constraint(:email)
    |> hash_password
    |> validate_required([:email, :password_hash])
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    password_hash = Bcrypt.hash_pwd_salt(password)

    changeset
    |> put_change(:password_hash, password_hash)
    |> put_change(:password_confirmation, nil)
  end

  defp hash_password(changeset) do
    changeset
  end
end
