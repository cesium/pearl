defmodule Pearl.Tickets.TicketType do
  @moduledoc """
  Ticket types for Tickets.
  """
  use Pearl.Schema

  alias Pearl.Tickets.Ticket

  @required_fields ~w(name priority description price active)a
  @optional_fields ~w()a

  @derive {Flop.Schema, sortable: [:priority], filterable: []}

  schema "ticket_types" do
    field :name, :string
    field :priority, :integer
    field :description, :string
    field :price, :integer
    field :active, :boolean

    has_many :tickets, Ticket

    timestamps(type: :utc_datetime)
  end

  def changeset(ticket_type, attrs) do
    ticket_type
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:tickets)
  end
end
