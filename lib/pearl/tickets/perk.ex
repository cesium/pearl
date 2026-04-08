defmodule Pearl.Tickets.Perk do
  @moduledoc """
  Perks for Ticket Types.
  """

  use Pearl.Schema

  @required_fields ~w(name description icon color active priority)a

  @derive {Flop.Schema, sortable: [:priority], filterable: []}

  schema "perks" do
    field :name, :string
    field :description, :string
    field :icon, :string
    field :color, :string
    field :active, :boolean
    field :priority, :integer
    field :allows_meals, :boolean, default: false

    many_to_many :ticket_types, Pearl.Tickets.TicketType, join_through: "ticket_types_perks"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(perk, attrs) do
    perk
    |> cast(attrs, @required_fields ++ [:allows_meals])
    |> validate_required(@required_fields)
  end
end
