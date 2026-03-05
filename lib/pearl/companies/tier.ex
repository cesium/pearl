defmodule Pearl.Companies.Tier do
  @moduledoc """
  Sponsor tiers for companies.
  """
  use Pearl.Schema

  @required_fields ~w(name priority color type)a
  @optional_fields ~w(full_cv_access)a

  @derive {Flop.Schema, sortable: [:priority], filterable: []}

  @tier_types [:sponsor, :partner]

  schema "tiers" do
    field :name, :string
    field :priority, :integer
    field :type, Ecto.Enum, values: @tier_types, default: :sponsor
    field :spotlight_multiplier, :float, default: 0.0
    field :max_spotlights, :integer, default: 1
    field :full_cv_access, :boolean, default: false
    field :color, :string

    has_many :companies, Pearl.Companies.Company, foreign_key: :tier_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tier, attrs) do
    tier
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @tier_types)
  end

  def changeset_multiplier(tier, attrs) do
    tier
    |> cast(attrs, [:spotlight_multiplier, :max_spotlights])
    |> validate_required([:spotlight_multiplier, :max_spotlights])
  end

  def list_tier_types, do: @tier_types
end
