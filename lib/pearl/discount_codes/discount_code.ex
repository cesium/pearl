defmodule Pearl.DiscountCodes.DiscountCode do
  @moduledoc """
   Module for the Discount Code
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Pearl.Tickets.TicketType

  @derive {
    Flop.Schema,
    filterable: [:code, :active],
    sortable: [:code, :amount, :active, :inserted_at],
    default_limit: 25
  }

  @required_fields ~w(code amount active usage_limit)a
  @optional_fields ~w()a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "discount_codes" do
    field :code, :string
    field :amount, :float
    field :active, :boolean, default: false
    field :usage_limit, :integer

    many_to_many :ticket_types, TicketType,
      join_through: "discount_codes_ticket_types",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(discount_code, attrs) do
    discount_code
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  @doc false
  def changeset_update_ticket_types(discount_code, ticket_types) do
    discount_code
    |> cast(%{}, @required_fields ++ @optional_fields)
    |> put_assoc(:ticket_types, ticket_types)
  end
end
