defmodule Pearl.Referrals.Referral do
  @moduledoc """
    Module for the Referral COde
  """

  use Pearl.Schema

  @derive {
    Flop.Schema,
    filterable: [:code], sortable: [:code], default_limit: 8
  }

  @required_fields ~w(code)a
  @optional_fields ~w(active)a

  schema "referrals" do
    field :code, :string
    field :active, :boolean, default: true

    has_many :attendees, Pearl.Accounts.Attendee

    timestamps(type: :utc_datetime)
  end

  def changeset(referral, attrs) do
    referral
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code, message: "This referral code already exists")
  end
end
