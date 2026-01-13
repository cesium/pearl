defmodule Pearl.Repo.Migrations.AddDominantColorToSpeaker do
  use Ecto.Migration

  def change do
    alter table(:speakers) do
      add :dominant_color, :map, default: %{r: 26, g: 26, b: 46}
    end
  end
end
