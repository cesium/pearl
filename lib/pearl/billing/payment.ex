defmodule Pearl.Billing.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(order_id amount status ticket_id)a

  schema "payments" do
    field :order_id, :string
    field :amount, :decimal
    field :status, Ecto.Enum, values: [:pending, :completed, :canceled], default: :pending

    belongs_to :ticket, Pearl.Tickets.Ticket, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
