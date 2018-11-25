defmodule Unsilo.Repo.Migrations.CreateSpots do
  use Ecto.Migration

  def change do
    create table(:spots) do
      add :name, :string
      add :domains, {:array, :string}
      add :user_id, :integer
      add :count, :integer, default: 0
      add :description, :string
      add :theme, :string
      add :background_color, :string
      add :allow_subscriptions, :boolean
      add :tagline, :string
      add :logo, :string

      timestamps()
    end
    
    create table(:subscribers) do
      add :email, :string
      add :spot_id, :integer

      timestamps()
    end
  end
end
