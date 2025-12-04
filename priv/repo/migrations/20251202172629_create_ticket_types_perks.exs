defmodule Pearl.Repo.Migrations.CreateTicketTypesPerks do
  use Ecto.Migration

  def change do
    create table(:ticket_types_perks, primary_key: false) do
      add :perk_id,
          references(:perks, type: :binary_id, on_delete: :delete_all)

      add :ticket_type_id,
          references(:ticket_types, type: :binary_id, on_delete: :delete_all),
          null: false
    end

    create index(:ticket_types_perks, [:perk_id])
    create index(:ticket_types_perks, [:ticket_type_id])
    create unique_index(:ticket_types_perks, [:perk_id, :ticket_type_id])
  end
end
