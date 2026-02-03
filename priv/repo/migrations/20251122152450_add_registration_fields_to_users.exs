defmodule Pearl.Repo.Migrations.AddRegistrationFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :phone, :string
      add :notes, :string
      add :university, :string
      add :city, :string
    end
  end
end
