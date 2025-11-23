defmodule Pearl.Tickets.TicketType do

  use Pearl.Schema

  alias Pearl.Tickets.Ticket

  @required_fields ~w(name description price)a
  @optional_fields ~w(ticket_id)a

  schema "ticket_type" do
    field :name, :string
    field :description, :string
    field :price, :integer
    # field :image, Uploaders.Ticket.Type - we don't know if there will be an image related to each ticket at the plataform level

    has_many :ticket, Ticket

    timestamps(type: :utc_datetime)
  end

  def changeset(ticket_type, attrs) do
    ticket_type
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

end
