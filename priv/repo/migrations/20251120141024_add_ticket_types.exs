defmodule Pearl.Repo.Migrations.AddTicketTypes do
  use Ecto.Migration

  def change do
    create table(:ticket_types, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :priority, :integer
      add :name, :string
      add :description, :string
      add :price, :integer
      add :active, :boolean

      timestamps(type: :utc_datetime)
    end
  end
end
