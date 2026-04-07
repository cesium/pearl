defmodule Pearl.Repo.Migrations.AddAllowsMealsToPerks do
  use Ecto.Migration

  def change do
    alter table(:perks) do
      add :allows_meals, :boolean, default: false, null: false
    end
  end
end
