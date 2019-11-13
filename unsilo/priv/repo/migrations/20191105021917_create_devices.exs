defmodule Unsilo.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :name, :string
      add :unsilo_uuid, :string
      add :uuid, :string
      add :type, :string
      add :sort_order, :integer, default: 0
      add :app_key, :string
      add :status, :string
      add :location_id, :integer

      timestamps()
    end
  end
end
