defmodule Pearl.Minigames.ScratchCard do
  @moduledoc """
  Scratch card minigame cards.
  """
  use Pearl.Schema

  @required_fields ~w(attendee_id is_revealed)a
  @optional_fields ~w(drop_id)a

  schema "scratch_cards" do
    field :is_revealed, :boolean, default: false

    belongs_to :attendee, Pearl.Accounts.Attendee
    belongs_to :drop, Pearl.Minigames.ScratchCardDrop

    many_to_many :symbols, Pearl.Minigames.ScratchCardSymbol, join_through: "cards_symbols"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scratch_card, attrs) do
    scratch_card
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:symbols)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:attendee_id)
    |> foreign_key_constraint(:drop_id)
  end
end
