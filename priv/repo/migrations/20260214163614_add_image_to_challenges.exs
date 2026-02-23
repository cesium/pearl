defmodule Pearl.Repo.Migrations.AddImageToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :image, :string, null: true
    end
  end
end
