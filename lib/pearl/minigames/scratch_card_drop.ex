defmodule Pearl.Minigames.ScratchCardDrop do
  use Pearl.Schema

  @required_fields ~w(probability max_per_attendee symbol)a
  @optional_fields ~w(prize_id badge_id tokens entries)a

  schema "scratch_card_drops" do
    field :probability, :float
    field :max_per_attendee, :integer
    field :tokens, :integer, default: 0
    field :entries, :integer, default: 0

    field :symbol, :string

    belongs_to :prize, Pearl.Minigames.Prize
    belongs_to :badge, Pearl.Contest.Badge

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scratch_card_drop, attrs) do
    scratch_card_drop
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_number(:probability, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
    |> validate_number(:max_per_attendee, greater_than_or_equal_to: 0)
    |> validate_number(:tokens, greater_than_or_equal_to: 0)
    |> validate_number(:entries, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:prize_id)
    |> foreign_key_constraint(:badge_id)
    |> validate_inclusion(:symbol, [
      "star",
      "coin",
      "void",
      "cesium",
      "enei",
      "bug",
      "trophy",
      "pointer"
    ])
    |> validate_required(@required_fields)
  end
end
