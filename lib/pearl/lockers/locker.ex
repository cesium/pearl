defmodule Pearl.Lockers.Locker do
  @moduledoc """
  Schema representing a physical locker.
  """

  use Pearl.Schema

  schema "lockers" do
    field :number, :integer

    many_to_many :attendees, Pearl.Accounts.Attendee, join_through: "attendee_lockers"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(locker, attrs) do
    locker
    |> cast(attrs, [:number])
    |> validate_required([:number])
    |> unique_constraint(:number)
  end
end
