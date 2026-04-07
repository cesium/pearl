defmodule Pearl.Repo.Seeds.Meals do
  import Ecto.Query

  alias Pearl.Repo
  alias Pearl.Tickets.{EventMeal, MealConsumption, Ticket}

  def run do
    seed_meals()
  end

  defp seed_meals do
    case Repo.all(MealConsumption) do
      [] ->
        seed_event_meals_and_consumptions()

      _ ->
        Mix.shell().info("Found meal consumptions, skipping seeding.")
    end
  end

  defp seed_event_meals_and_consumptions do
    tickets =
      Ticket
      |> Repo.all()
      |> Repo.preload(ticket_type: :perks)

    tickets_with_meals =
      Enum.filter(tickets, fn ticket ->
        ticket.ticket_type && Enum.any?(ticket.ticket_type.perks, &(&1.name == "Meals"))
      end)

    if Enum.empty?(tickets_with_meals) do
      Mix.shell().error("No tickets with Meals perk found. Please run tickets seed first.")
    else
      event_meals = ensure_event_meals()
      seed_consumptions(tickets_with_meals, event_meals)
      Mix.shell().info("Seeded meal consumptions successfully.")
    end
  end

  defp ensure_event_meals do
    case Repo.all(EventMeal) do
      [] ->
        meals = [
          %{date: ~D[2026-04-09], meal_type: "Lunch", description: "Day 1 Lunch", start_time: ~T[11:30:00], end_time: ~T[14:30:00]},
          %{date: ~D[2026-04-09], meal_type: "Dinner", description: "Day 1 Dinner", start_time: ~T[19:00:00], end_time: ~T[21:30:00]},
          %{date: ~D[2026-04-10], meal_type: "Lunch", description: "Day 2 Lunch", start_time: ~T[11:30:00], end_time: ~T[14:30:00]}
        ]

        Enum.map(meals, fn attrs ->
          %EventMeal{} |> EventMeal.changeset(attrs) |> Repo.insert!()
        end)

      existing ->
        existing
    end
  end

  defp seed_consumptions(tickets_with_meals, event_meals) do
    Enum.each(tickets_with_meals, fn ticket ->
      random_meal = Enum.random(event_meals)

      %MealConsumption{}
      |> MealConsumption.changeset(%{
        user_id: ticket.user_id,
        event_meal_id: random_meal.id
      })
      |> Repo.insert()
    end)
  end
end

Pearl.Repo.Seeds.Meals.run()
