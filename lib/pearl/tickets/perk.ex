defmodule Pearl.Tickets.Perk do
  @moduledoc """
  Perks for Ticket Types.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_fields ~w(name description icon color active)a

  schema "perks" do
    field :name, :string
    field :description, :string
    field :icon, :string
    field :color, :string
    field :active, :boolean

    many_to_many :ticket_types, Pearl.Tickets.TicketType,
      join_through: "ticket_types_perks"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(perk, attrs) do
    perk
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
