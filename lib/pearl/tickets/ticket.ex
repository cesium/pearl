defmodule Pearl.Tickets.Ticket do
  @moduledoc """
  Tickets to access the event.
  """

  use Pearl.Schema

  alias Pearl.Accounts.User
  alias Pearl.Tickets.TicketType

  @required_fields ~w(paid user_id ticket_type_id)a

  schema "tickets" do
    field :paid, :boolean

    belongs_to :user, User
    belongs_to :ticket_type, TicketType

    timestamps(type: :utc_datetime)
  end

  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:user_id)
    |> unsafe_validate_unique(:user_id, Pearl.Repo)
  end

end
