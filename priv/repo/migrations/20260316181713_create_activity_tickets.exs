defmodule Pearl.Repo.Migrations.CreateActivityTickets do
  use Ecto.Migration

  def change do
    create table(:activity_tickets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :paid, :boolean, default: false, null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      add :ticket_type_id, references(:ticket_types, type: :binary_id, on_delete: :nothing),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:activity_tickets, [:user_id])
    create index(:activity_tickets, [:ticket_type_id])
  end
end
