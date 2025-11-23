defmodule Pearl.Repo.Migrations.AddTicketTypes do
  use Ecto.Migration

  def change do
    create table(:ticket_types, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string
      add :price, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
