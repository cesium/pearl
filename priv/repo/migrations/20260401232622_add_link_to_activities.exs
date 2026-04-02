defmodule Pearl.Repo.Migrations.AddLinkToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :link, :string
    end
  end
end
