defmodule Pearl.Accounts.Course do
  @moduledoc """
  A course the user is enrolled in.
  """
  use Pearl.Schema

  alias Pearl.Accounts.Attendee

  @required_fields ~w(name)a

  schema "courses" do
    field :name, :string

    has_many :attendees, Attendee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
