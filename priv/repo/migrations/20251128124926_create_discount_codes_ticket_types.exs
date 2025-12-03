defmodule Pearl.Repo.Migrations.CreateDiscountCodesTicketTypes do
  use Ecto.Migration

  def change do
    create table(:discount_codes_ticket_types, primary_key: false) do
      add :discount_code_id,
        references(:discount_codes, type: :binary_id, on_delete: :delete_all), null: false

      add :ticket_type_id,
        references(:ticket_types, type: :binary_id, on_delete: :delete_all),
        null: false
    end

    create index(:discount_codes_ticket_types, [:discount_code_id])
    create index(:discount_codes_ticket_types, [:ticket_type_id])
    create unique_index(:discount_codes_ticket_types, [:discount_code_id, :ticket_type_id])
  end
end
