defmodule Pearl.Repo.Migrations.AddPriorityToPerks do
  use Ecto.Migration

  def change do
    alter table(:perks) do
      add :priority, :integer
    end
  end
end
