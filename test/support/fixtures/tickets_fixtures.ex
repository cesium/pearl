defmodule Pearl.TicketsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pearl.Tickets` context.
  """

  @doc """
  Generate a perk.
  """
  def perk_fixture(attrs \\ %{}) do
    {:ok, perk} =
      attrs
      |> Enum.into(%{
        color: "some color",
        description: "some description",
        icon: "some icon",
        name: "some name",
        priority: "1",
        active: true
      })
      |> Pearl.Tickets.create_perk()

    perk
  end

  @doc """
  Generate a event_meal.
  """
  def event_meal_fixture(attrs \\ %{}) do
    {:ok, event_meal} =
      attrs
      |> Enum.into(%{
        date: ~D[2026-04-01],
        description: "some description",
        meal_type: "some meal_type"
      })
      |> Pearl.Tickets.create_event_meal()

    event_meal
  end
end
