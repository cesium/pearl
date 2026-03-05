defmodule Pearl.Repo.Migrations.AlterTiers do
  use Ecto.Migration

  def change do
    alter table(:tiers) do
      add :type, :string, null: false, default: "sponsor"
    end
  end
end
