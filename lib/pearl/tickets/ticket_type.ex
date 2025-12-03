defmodule Pearl.Tickets.TicketType do
  @moduledoc """
  Ticket types for Tickets.
  """
  use Pearl.Schema

  alias Pearl.Tickets.Perk
  alias Pearl.DiscountCodes.DiscountCode
  alias Pearl.Tickets.Perk
  alias Pearl.Tickets.Ticket

  @required_fields ~w(name priority price active)a
  @optional_fields ~w()a

  @derive {Flop.Schema, sortable: [:priority], filterable: []}

  schema "ticket_types" do
    field :name, :string
    field :priority, :integer
    field :price, :float
    field :active, :boolean
    field :product_key, :binary_id

    has_many :tickets, Ticket

    many_to_many :perks, Perk,
      join_through: "ticket_types_perks",
      on_replace: :delete

    many_to_many :discount_codes, DiscountCode,
      join_through: "discount_codes_ticket_types",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(ticket_type, attrs) do
    ticket_type
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:tickets)
  end

  def changeset_update_perks(ticket_type, perks) do
    ticket_type
    |> cast(%{}, @required_fields ++ @optional_fields)
    |> put_assoc(:perks, perks)
  end
end
