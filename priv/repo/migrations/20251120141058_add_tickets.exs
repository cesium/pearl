defmodule Pearl.Repo.Migrations.AddTickets do
  use Ecto.Migration

  def change do
    create table(:tickets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :paid, :boolean, null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :nothing), null: false
      add :ticket_type_id, references(:ticket_types, type: :binary_id, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tickets, [:user_id])
    create index(:tickets, [:ticket_type_id])
  end
end
