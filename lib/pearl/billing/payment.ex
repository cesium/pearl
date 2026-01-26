defmodule Pearl.Billing.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :order_id, :string
    field :amount, :decimal
    field :status, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:order_id, :amount, :status])
    |> validate_required([:order_id, :amount, :status])
  end
end
