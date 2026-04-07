defmodule Pearl.Repo.Migrations.CreateLockerItems do
  use Ecto.Migration

  def change do
    create table(:locker_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string
      add :picture, :string

      add :stored, :boolean, default: true

      add :withdrawn_at, :utc_datetime

      add :attendee_locker_id,
          references(:attendee_lockers, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:locker_items, [:attendee_locker_id])
  end
end
