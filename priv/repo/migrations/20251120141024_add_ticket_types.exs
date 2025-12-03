defmodule Pearl.Repo.Migrations.AddTicketTypes do
  use Ecto.Migration

  def change do
    create table(:ticket_types, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :priority, :integer
      add :name, :string
      add :price, :float
      add :active, :boolean
      add :product_key, :binary_id

      timestamps(type: :utc_datetime)
    end
  end
end
