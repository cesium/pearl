defmodule Pearl.Repo.Migrations.AddReferrals do
  use Ecto.Migration

  def change do

    create table(:referrals, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string, null: false
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:referrals, [:code])

    alter table(:attendees) do
      add :referral_id, references(:referrals, type: :binary_id, on_delete: :nilify_all), null: true
    end

    create index(:attendees, [:referral_id])
  end
end
