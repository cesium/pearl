defmodule Pearl.Tickets.EventMeal do
  @moduledoc """
  Tracks an event meal with its date, time and type.
  """

  use Pearl.Schema

  @derive {Flop.Schema, sortable: [:date, :meal_type], filterable: [:date, :meal_type]}

  schema "event_meals" do
    field :date, :date
    field :meal_type, :string
    field :description, :string
    field :start_time, :time, default: ~T[11:30:00]
    field :end_time, :time, default: ~T[14:30:00]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_meal, attrs) do
    event_meal
    |> cast(attrs, [:date, :meal_type, :description, :start_time, :end_time])
    |> validate_required([:date, :meal_type, :description, :start_time, :end_time])
  end
end
