defmodule Pearl.Tickets.TicketType do
  @moduledoc """
  Ticket types for Tickets.
  """
  use Pearl.Schema

  alias Pearl.DiscountCodes.DiscountCode
  alias Pearl.Tickets.{Perk, Ticket}
  alias Pearl.Activities.Activity

  @required_fields ~w(name priority price active product_key type)a
  @optional_fields ~w(activity_id)a

  @derive {Flop.Schema, sortable: [:priority], filterable: []}

  schema "ticket_types" do
    field :name, :string
    field :priority, :integer
    field :price, :float
    field :active, :boolean
    field :product_key, :binary_id
    field :type, Ecto.Enum, values: [:event, :activity], default: :event

    belongs_to :activity, Activity

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
    |> validate_activity_id_for_type()
    |> foreign_key_constraint(:tickets)
    |> foreign_key_constraint(:activity_id)
  end

  def changeset_update_perks(ticket_type, perks) do
    ticket_type
    |> cast(%{}, @required_fields ++ @optional_fields)
    |> put_assoc(:perks, perks)
  end

  defp validate_activity_id_for_type(changeset) do
    type = get_field(changeset, :type)
    activity_id = get_field(changeset, :activity_id)

    case type do
      :event ->
        if is_nil(activity_id) do
          changeset
        else
          add_error(changeset, :activity_id, "must be empty when type is :event")
        end

      :activity ->
        if is_nil(activity_id) do
          add_error(changeset, :activity_id, "can't be blank when type is :activity")
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
