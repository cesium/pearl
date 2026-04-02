defmodule Pearl.Repo.Migrations.AddActivityTicketIdToPayments do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :activity_ticket_id,
          references(:activity_tickets, type: :binary_id, on_delete: :nothing)
    end
  end
end
