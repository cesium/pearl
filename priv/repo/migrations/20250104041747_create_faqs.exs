defmodule Pearl.Repo.Migrations.CreateFaqs do
  use Ecto.Migration

  def change do
    create table(:faqs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :topic, :string
      add :answer, :text
      add :question, :string
      add :is_article, :boolean, default: false

      timestamps()
    end
  end
end
