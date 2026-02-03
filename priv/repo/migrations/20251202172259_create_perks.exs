defmodule Pearl.Repo.Migrations.CreatePerks do
  use Ecto.Migration

  def change do
    create table(:perks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string
      add :icon, :string
      add :color, :string
      add :active, :boolean

      timestamps(type: :utc_datetime)
    end
  end
end
