defmodule Pearl.Spotlights.Spotlight do
  @moduledoc """
  Spotlight schema.
  """
  use Pearl.Schema

  @required_fields ~w(end company_id)a

  schema "spotlights" do
    field :end, :utc_datetime

    belongs_to :company, Pearl.Companies.Company

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(spotlight, attrs) do
    spotlight
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:company_id)
  end
end
