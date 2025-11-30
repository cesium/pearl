defmodule Pearl.Minigames.ScratchCard do
  @moduledoc """
  Scratch card minigame cards.
  """
  use Pearl.Schema

  @required_fields ~w(attendee_id symbols is_revealed)a
  @optional_fields ~w(prize_id)a

  schema "scratch_cards" do
    belongs_to :attendee, Pearl.Accounts.Attendee
    field :symbols, {:array, :string}
    field :is_revealed, :boolean, default: false
    belongs_to :prize, Pearl.Minigames.Prize

    timestamps(type: :utc_datetime)
  end

  def changeset(scratch_card, attrs) do
    scratch_card
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:attendee_id)
    |> foreign_key_constraint(:prize_id)
    |> validate_length(:symbols, is: 6)
  end
end
