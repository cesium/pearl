defmodule Pearl.Repo.Migrations.AddRegistrationFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :ticket_type, :string
      add :notes, :string
      add :university, :string
      add :city, :string
      add :dietary_restrictions, :string
    end
  end
end
