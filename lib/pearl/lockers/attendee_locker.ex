defmodule Pearl.Lockers.AttendeeLocker do
  @moduledoc """
  Schema for active/inactive attendee-to-locker session assignments.
  """

  use Pearl.Schema
  import Ecto.Changeset

  @required_fields ~w(active attendee_id locker_id)a

  schema "attendee_lockers" do
    field :active, :boolean, default: true

    field :attendee_id, :binary_id
    field :locker_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attendee_locker, attrs) do
    attendee_locker
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
