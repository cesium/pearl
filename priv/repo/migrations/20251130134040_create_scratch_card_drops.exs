defmodule Pearl.Repo.Migrations.CreateScratchCardDrops do
  use Ecto.Migration

  def change do
    create table(:scratch_card_drops, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :probability, :float
      add :max_per_attendee, :integer
      add :tokens, :integer, default: 0
      add :entries, :integer, default: 0

      add :symbol, :string

      add :prize_id, references(:prizes, type: :binary_id, on_delete: :delete_all)
      add :badge_id, references(:badges, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:scratch_card_drops, [:prize_id])
    create index(:scratch_card_drops, [:badge_id])
  end
end
