defmodule Pearl.DiscountCodes.DiscountCode do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "discount_codes" do
    field :code, :string
    field :amount, :integer
    field :active, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(discount_code, attrs) do
    discount_code
    |> cast(attrs, [:code, :amount, :active])
    |> validate_required([:code, :amount, :active])
  end
end
