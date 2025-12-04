defmodule Pearl.Minigames.ScratchCard do
  @moduledoc """
  Scratch card minigame cards.
  """
  use Pearl.Schema

  @required_fields ~w(attendee_id symbols is_revealed)a
  @optional_fields ~w(drop_id)a

  schema "scratch_cards" do
    field :symbols, {:array, :string}
    field :is_revealed, :boolean, default: false

    belongs_to :attendee, Pearl.Accounts.Attendee
    belongs_to :drop, Pearl.Minigames.ScratchCardDrop

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scratch_card, attrs) do
    scratch_card
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:attendee_id)
    |> foreign_key_constraint(:drop_id)
    |> validate_length(:symbols, is: 6)
  end
end
