defmodule Pearl.Repo.Migrations.AddAccentColorToSpeaker do
  use Ecto.Migration

  def change do
    alter table(:speakers) do
      add :accent_color, :map, default: %{r: 26, g: 26, b: 46}
    end
  end
end
