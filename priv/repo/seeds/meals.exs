defmodule Pearl.Repo.Seeds.Meals do
  import Ecto.Query

  alias Pearl.Repo
  alias Pearl.Tickets.{MealConsumption, Ticket}

  def run do
    seed_meals()
  end

  defp seed_meals do
    case Repo.all(MealConsumption) do
      [] ->
        tickets =
          Ticket
          |> Repo.all()
          |> Repo.preload(ticket_type: :perks)

        tickets_with_meals =
          Enum.filter(tickets, fn ticket ->
            ticket.ticket_type &&
              Enum.any?(ticket.ticket_type.perks, &(&1.name == "Meals"))
          end)

        if Enum.empty?(tickets_with_meals) do
          Mix.shell().error("No tickets with Meals perk found. Please run tickets seed first.")
        else
          Enum.each(tickets_with_meals, fn ticket ->
            days = [9, 10, 11, 12]
            meals = [1, 2]

            # Seed a couple of random meals for each user that has meal access
            for day <- Enum.take_random(days, 2), meal <- Enum.take_random(meals, 1) do
              %MealConsumption{}
              |> MealConsumption.changeset(%{
                user_id: ticket.user_id,
                day: day,
                meal_number: meal
              })
              |> Repo.insert()
            end
          end)

          Mix.shell().info("Seeded meal consumptions successfully.")
        end

      _ ->
        Mix.shell().info("Found meal consumptions, skipping seeding.")
    end
  end
end

Pearl.Repo.Seeds.Meals.run()
