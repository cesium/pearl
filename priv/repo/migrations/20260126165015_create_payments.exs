defmodule Pearl.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :order_id, :string
      add :amount, :decimal
      add :status, :string

      add :ticket_id, references(:tickets, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
  end
end
