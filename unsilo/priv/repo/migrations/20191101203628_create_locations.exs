  defmodule Unsilo.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string
      add :lat, :float
      add :lng, :float
      add :type, :integer
      add :address, :string
      add :phone, :string
      add :user_id, :integer

      add :access, StatusEnum.type()
      add :sort_order, :integer, default: 0

      timestamps()
    end

  end
end
