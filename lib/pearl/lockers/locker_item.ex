defmodule Pearl.Lockers.LockerItem do
  @moduledoc """
  Schema for items stored in attendee lockers.
  """

  use Pearl.Schema

  @required_fields ~w(name attendee_locker_id)a
  @optional_fields ~w(description picture stored withdrawn_at)a

  schema "locker_items" do
    field :name, :string
    field :description, :string
    field :picture, Pearl.Uploaders.LockerItems.Type

    field :stored, :boolean, default: true

    field :withdrawn_at, :utc_datetime

    belongs_to :attendee_locker, Pearl.Lockers.AttendeeLocker

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(locker_item, attrs) do
    locker_item
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:attendee_locker)
    |> validate_required(@required_fields)
  end

  @doc false
  def picture_changeset(locker_item, attrs) do
    locker_item
    |> cast_attachments(attrs, [:picture])
  end
end
