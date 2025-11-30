defmodule Pearl.DiscountCodes.DiscountCode do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pearl.Tickets.TicketType

  @derive {
    Flop.Schema,
    filterable: [:code, :active],
    sortable: [:code, :amount, :active, :inserted_at],
    default_limit: 25
  }

  @required_fields ~w(code amount active)a
  @optional_fields ~w()a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "discount_codes" do
    field :code, :string
    field :amount, :integer
    field :active, :boolean, default: false

    many_to_many :ticket_types, TicketType, join_through: "discount_codes_ticket_types", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(discount_code, attrs) do
    discount_code
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> put_ticket_types(attrs)
  end

  defp put_ticket_types(changeset, %{ticket_type_ids: ticket_type_ids}) when is_list(ticket_type_ids) do
    ticket_types =
      ticket_type_ids
      |> Enum.reject(&(&1 == "" or is_nil(&1)))
      |> Enum.map(&Pearl.TicketTypes.get_ticket_type!/1)

    put_assoc(changeset, :ticket_types, ticket_types)
  end

  defp put_ticket_types(changeset, %{"ticket_type_ids" => ticket_type_ids}) when is_list(ticket_type_ids) do
    ticket_types =
      ticket_type_ids
      |> Enum.reject(&(&1 == "" or is_nil(&1)))
      |> Enum.map(&Pearl.TicketTypes.get_ticket_type!/1)

    put_assoc(changeset, :ticket_types, ticket_types)
  end

  defp put_ticket_types(changeset, _attrs), do: changeset
end
