defmodule Pearl.Repo.Migrations.CreateHorseRaceBets do
  use Ecto.Migration

  def change do
    create table(:horse_race_bets, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :attendee_id, references(:attendees, type: :binary_id, on_delete: :delete_all),
        null: false

      add :race_id, :string, null: false
      add :horse_number, :integer, null: false
      add :bet_amount, :decimal, precision: 10, scale: 2, null: false
      add :status, :string, default: "pending", null: false
      add :payout_amount, :decimal, precision: 10, scale: 2
      add :processed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:horse_race_bets, [:attendee_id])
    create index(:horse_race_bets, [:race_id])
    create index(:horse_race_bets, [:status])
    create index(:horse_race_bets, [:race_id, :status])
  end
end
