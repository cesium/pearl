defmodule Pearl.Repo.Migrations.CreateAttendeeLockers do
  use Ecto.Migration

  def change do
    create table(:attendee_lockers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :active, :boolean, default: true

      add :attendee_id, references(:attendees, type: :binary_id, on_delete: :delete_all)
      add :locker_id, references(:lockers, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:attendee_lockers, [:attendee_id])
    create index(:attendee_lockers, [:locker_id])
  end
end
