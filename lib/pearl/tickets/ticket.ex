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

  @required_fields ~w(paid allergens tshirt_size diet user_id ticket_type_id)a
  @optional_fields ~w(disabilities intended_transport_to_enei has_attended_enei_before)a

  schema "tickets" do
    field :paid, :boolean
    field :disabilities, :string
    field :allergens, :string
    field :tshirt_size, :string
    field :diet, :string
    field :intended_transport_to_enei, :string
    field :has_attended_enei_before, :string

    belongs_to :user, User
    belongs_to :ticket_type, TicketType, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:user_id)
    |> cast_assoc(:user, with: &User.profile_changeset/2)
    |> unsafe_validate_unique(:user_id, Repo)
    |> foreign_key_constraint(:ticket_type_id)
  end

  def changeset_precautions(ticket, attrs) do
    ticket
    |> cast(attrs, [:disabilities, :allergens])
    |> validate_allergens(attrs)
  end

  defp validate_allergens(changeset, attrs) do
    has_allergens = Map.get(attrs, "has_allergens")

    case has_allergens do
      "yes" -> validate_required(changeset, [:allergens])
      _ -> changeset
    end
  end

  def changeset_informations(ticket, attrs) do
    ticket
    |> cast(attrs, [:tshirt_size, :diet, :intended_transport_to_enei, :has_attended_enei_before])
    |> validate_required([:tshirt_size, :diet])
  end
end
