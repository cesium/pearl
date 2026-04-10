defmodule Pearl.Minigames.HorseRaceBet do
  @moduledoc """
  Horse race bet schema.
  Represents a bet placed by an attendee on a specific horse in a race.
  """
  use Pearl.Schema

  alias Pearl.Accounts.Attendee

  @required_fields ~w(attendee_id race_id horse_number bet_amount)a
  @optional_fields ~w(status payout_amount processed_at)a

  @statuses ~w(pending won lost cancelled)

  schema "horse_race_bets" do
    field :race_id, :string
    field :horse_number, :integer
    field :bet_amount, :decimal
    field :status, :string, default: "pending"
    field :payout_amount, :decimal
    field :processed_at, :utc_datetime

    belongs_to :attendee, Attendee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(horse_race_bet, attrs) do
    horse_race_bet
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:horse_number, greater_than: 0)
    |> validate_number(:bet_amount, greater_than: 0)
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:attendee_id)
  end

  @doc """
  Returns the list of valid bet statuses.
  """
  def statuses, do: @statuses
end
