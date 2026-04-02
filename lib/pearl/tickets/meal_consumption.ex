defmodule Pearl.Tickets.MealConsumption do
  @moduledoc """
  Tracks when an attendee consumes a meal.
  """

  use Pearl.Schema

  alias Pearl.Accounts.User
  alias Pearl.Tickets.EventMeal

  @required_fields ~w(event_meal_id user_id)a

  schema "meal_consumptions" do
    belongs_to :event_meal, EventMeal
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(meal_consumption, attrs) do
    meal_consumption
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:user_id, :event_meal_id],
      name: :meal_consumptions_user_event_meal_index
    )
  end
end
