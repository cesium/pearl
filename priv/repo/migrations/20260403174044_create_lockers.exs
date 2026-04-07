defmodule Pearl.Repo.Migrations.CreateLockers do
  use Ecto.Migration

  def change do
    create table(:lockers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :number, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:lockers, [:number])
  end
end
