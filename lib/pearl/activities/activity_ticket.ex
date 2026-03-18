defmodule Pearl.Activities.ActivityTicket do
  @moduledoc """
  ActivityTicket schema.

  """

  use Pearl.Schema
  import Ecto.Changeset

  alias Pearl.Accounts.User
  alias Pearl.Tickets.TicketType

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "activity_tickets" do
    field :paid, :boolean, default: false

    belongs_to :user, User
    belongs_to :ticket_type, TicketType, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity_ticket, attrs) do
    activity_ticket
    |> cast(attrs, [:paid, :user_id, :ticket_type_id])
    |> validate_required([:paid, :user_id, :ticket_type_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:ticket_type_id)
  end
end
