defmodule Pearl.Accounts.Credential do
  @moduledoc """
  Attendee's physical credentials.
  """
  use Pearl.Schema

  schema "credentials" do
    belongs_to :attendee, Pearl.Accounts.Attendee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:attendee_id])
    |> cast_assoc(:attendee)
  end
end
