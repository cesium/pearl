defmodule Pearl.Repo.Migrations.AlterUserTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :dietary_restrictions, :string
      add :phone, :string
    end
  end
end
