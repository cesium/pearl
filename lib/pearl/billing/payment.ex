defmodule Pearl.Billing.Payment do
  @moduledoc """
  The Payment schema.
  """
  use Pearl.Schema

  @required_fields ~w(order_id amount status)a
  @optional_fields ~w(ticket_id activity_ticket_id)a

  schema "payments" do
    field :order_id, :string
    field :amount, :decimal
    field :status, Ecto.Enum, values: [:pending, :completed, :canceled], default: :pending

    belongs_to :ticket, Pearl.Tickets.Ticket, type: :binary_id
    belongs_to :activity_ticket, Pearl.Activities.ActivityTicket, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_ticket_presence()
    |> foreign_key_constraint(:ticket_id)
    |> foreign_key_constraint(:activity_ticket_id)
  end

  defp validate_ticket_presence(changeset) do
    ticket_id = get_field(changeset, :ticket_id)
    activity_ticket_id = get_field(changeset, :activity_ticket_id)

    if is_nil(ticket_id) and is_nil(activity_ticket_id) do
      add_error(changeset, :ticket_id, "either ticket_id or activity_ticket_id must be present")
    else
      changeset
    end
  end
end
