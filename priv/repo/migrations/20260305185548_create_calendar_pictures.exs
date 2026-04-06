defmodule Pearl.Repo.Migrations.CreateCalendarPictures do
  use Ecto.Migration

  def change do
    create table(:calendar_pictures, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date
      add :image, :string

      timestamps(type: :utc_datetime)
    end
  end
end
