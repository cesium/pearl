defmodule Pearl.Repo.Migrations.CreateMealConsumptions do
  use Ecto.Migration

  def change do
    create table(:meal_consumptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      add :event_meal_id, references(:event_meals, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:meal_consumptions, [:user_id])
    create index(:meal_consumptions, [:event_meal_id])

    create unique_index(:meal_consumptions, [:user_id, :event_meal_id],
             name: :meal_consumptions_user_event_meal_index
           )
  end
end
