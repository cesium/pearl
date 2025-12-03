defmodule Pearl.Repo.Migrations.CreateDiscountCodes do
  use Ecto.Migration

  def change do
    create table(:discount_codes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string
      add :amount, :float
      add :active, :boolean, default: false, null: false
      add :usage_limit, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
