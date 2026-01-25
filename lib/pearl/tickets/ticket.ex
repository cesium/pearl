defmodule Pearl.Tickets.Ticket do
  @moduledoc """
  Tickets to access the event.
  """

  use Pearl.Schema

  alias Pearl.Accounts.User
  alias Pearl.Repo
  alias Pearl.Tickets.TicketType

  @derive {
    Flop.Schema,
    filterable: [:paid, :user_name],
    sortable: [:paid, :inserted_at, :ticket_type],
    default_limit: 11,
    join_fields: [
      ticket_type: [
        binding: :ticket_type,
        field: :name,
        path: [:ticket_type, :name],
        ecto_type: :string
      ],
      user_name: [
        binding: :user,
        field: :name,
        path: [:user, :name],
        ecto_type: :string
      ]
    ]
  }

  @required_fields ~w(paid user_id ticket_type_id)a

  schema "tickets" do
    field :paid, :boolean

    belongs_to :user, User
    belongs_to :ticket_type, TicketType, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:user_id)
    |> cast_assoc(:user, with: &User.profile_changeset/2)
    |> unsafe_validate_unique(:user_id, Repo)
    |> foreign_key_constraint(:ticket_type_id)
  end
end
