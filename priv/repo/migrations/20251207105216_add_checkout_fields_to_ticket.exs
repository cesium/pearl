defmodule Pearl.Repo.Migrations.K do
  use Ecto.Migration

  def change do
    alter table(:tickets) do
      add :disabilities, :string
      add :allergens, :string
      add :tshirt_size, :string
      add :diet, :string
      add :intended_transport_to_enei, :string
      add :has_attended_enei_before, :string
    end
  end
end
