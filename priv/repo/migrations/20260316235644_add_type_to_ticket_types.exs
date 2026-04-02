defmodule Pearl.Repo.Migrations.AddTypeToTicketTypes do
  use Ecto.Migration

  def change do
    alter table(:ticket_types) do
      add :type, :string, default: "event", null: false

      add :activity_id, references(:activities, type: :binary_id, on_delete: :nilify_all)
    end
  end
end
