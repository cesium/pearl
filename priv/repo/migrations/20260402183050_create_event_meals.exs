defmodule Pearl.Repo.Migrations.CreateEventMeals do
  use Ecto.Migration

  def change do
    create table(:event_meals, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date, null: false
      add :meal_type, :string, null: false
      add :description, :string, null: false
      add :start_time, :time, null: false, default: "11:30:00"
      add :end_time, :time, null: false, default: "14:30:00"

      timestamps(type: :utc_datetime)
    end
  end
end
