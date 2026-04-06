defmodule Pearl.Repo.Migrations.AddAccentColorToSpeaker do
  use Ecto.Migration

  def change do
    alter table(:speakers) do
      add :accent_color, :string, default: "#811824"
    end
  end
end
