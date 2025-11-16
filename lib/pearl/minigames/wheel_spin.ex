defmodule Pearl.Minigames.WheelSpin do
  @moduledoc """
  Lucky wheel minigame spin result
  """

  use Pearl.Schema

  @required_fields ~w(attendee_id drop_id)a

  schema "wheel_spins" do
    belongs_to :attendee, Pearl.Accounts.Attendee
    belongs_to :drop, Pearl.Minigames.WheelDrop

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wheel_spin, attrs) do
    wheel_spin
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
