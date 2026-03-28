defmodule Pearl.Repo.Seeds.Tickets do
  import Ecto.Query

  alias Pearl.Accounts.User
  alias Pearl.Activities.Activity
  alias Pearl.Billing
  alias Pearl.{Perks, Repo, TicketTypes, Tickets}
  alias Pearl.Tickets.{Perk, Ticket, TicketType}

  @perks [
    %{name: "Entry", description: "Entrada nos 4 dias do evento", icon: "fa-ticket-solid", color: "#D93044", active: true, priority: 0},
    %{name: "Meals", description: "Refeições durante todo o evento", icon: "fa-utensils-solid", color: "#F18F01", active: true, priority: 1},
    %{name: "Accommodation", description: "Estadia no Pavilhão", icon: "fa-bed-solid", color: "#2E86AB", active: true, priority: 2},

    %{name: "Arraial Minhoto Entry", description: "Entrada no Arraial Minhoto", icon: "fa-ticket-solid", color: "#8B4513", active: true, priority: 3},
    %{name: "Rally pela Sé Entry", description: "Participação no Rally pela Sé", icon: "fa-ticket-solid", color: "#556B2F", active: true, priority: 4}
  ]

  @ticket_types [
    %{name: "Passe Geral", description: "A nice ticket", price: 15, active: true, product_key: "b757d845-bbcd-4c10-ad6f-4effe3406a3c", priority: 0, perks: ["Entry"], type: :event},
    %{name: "Passe Geral com Refeições", description: "A much nicer ticket", price: 25, active: true, product_key: "021743b2-6ff1-4666-b70c-977c303a5da1", priority: 1, perks: ["Entry", "Meals"], type: :event},
    %{name: "Passe Geral com Refeições e Alojamento da Universidade do Minho",
    description: "An awesome ticket", price: 35, active: true, product_key: "0ff1e663-481a-4e42-9a52-a4ac02b72437", priority: 2, perks: ["Entry", "Meals", "Accommodation"], type: :event},

    %{name: "Bilhete Arraial Minhoto", description: "Acesso exclusivo ao Arraial Minhoto", price: 5, active: true, product_key: "a1b2c3d4-e5f6-4a1b-8c9d-0e1f2a3b4c5d", priority: 3, perks: ["Arraial Minhoto Entry"], type: :activity},
    %{name: "Bilhete Rally pela Sé", description: "Acesso exclusivo ao Rally pela Sé", price: 3, active: true, product_key: "f1e2d3c4-b5a6-4f1e-8d9c-0b1a2f3e4d5c", priority: 4, perks: ["Rally pela Sé Entry"], type: :activity}
  ]

  def run do
    seed_perks()
    seed_ticket_types()
    seed_tickets()
    seed_activity_tickets()
    seed_payments()
  end

  defp seed_perks do
    case Repo.all(Perk) do
      [] ->
        Enum.each(@perks, &insert_perk/1)

      _ ->
        Mix.shell().info("Found perks, skipping seeding.")
    end
  end

  defp insert_perk(attrs) do
    case Perks.create_perk(attrs) do
      {:ok, _perk} ->
        nil

      {:error, _changeset} ->
        Mix.shell().error("Failed to insert perk: #{attrs.name}")
    end
  end

  defp seed_ticket_types do
    activities = Repo.all(Activity)

    case Repo.all(TicketType) do
      [] ->
        Enum.each(@ticket_types, fn attrs ->
          attrs
          |> assign_activity_id(activities)
          |> insert_ticket_type()
        end)

        Mix.shell().info("Seeded ticket types successfully.")

      _ ->
        Mix.shell().info("Found ticket types, skipping seeding.")
    end
  end

  defp insert_ticket_type(attrs) do
    {perk_names, ticket_type_attrs} = Map.pop(attrs, :perks, [])

    case TicketTypes.create_ticket_type(ticket_type_attrs) do
      {:ok, ticket_type} ->
        perk_ids = Repo.all(from p in Perk, where: p.name in ^perk_names, select: p.id)

        case TicketTypes.upsert_ticket_type_perks(ticket_type, perk_ids) do
          {:ok, _ticket_type} ->
            nil

          {:error, changeset} ->
            Mix.shell().error("Failed to associate perks for ticket type: #{attrs.name}: #{inspect(changeset.errors)}")
        end

      {:error, changeset} ->
        Mix.shell().error("Failed to insert ticket type: #{ticket_type_attrs.name} - #{inspect(changeset.errors)}")
    end
  end

  defp assign_activity_id(%{type: :activity} = attrs, activities) do
    case activities do
      [] ->
        Mix.raise("Cannot create activity ticket #{attrs.name}: no activities seeded.")

      _ ->
        activity =
          Enum.find(activities, &String.contains?(&1.title, attrs.name |> String.split() |> List.first() || "")) ||
            List.first(activities)

        Map.put(attrs, :activity_id, activity.id)
    end
  end

  defp assign_activity_id(attrs, _activities), do: attrs

  defp seed_tickets do
    case Repo.all(Ticket) do
      [] ->
        users = Repo.all(from u in User, where: u.type == :attendee, limit: 20)

        if Enum.empty?(users) do
          Mix.shell().error("No attendee users found. Please create users first.")
        else
          event_ticket_names = ["Passe Geral", "Passe Geral com Refeições", "Passe Geral com Refeições e Alojamento da Universidade do Minho"]
          ticket_types = Repo.all(from t in TicketType, where: t.name in ^event_ticket_names)

          empty_ticket_types?(ticket_types, users)
        end
      _ ->
        Mix.shell().info("Found tickets, skipping seeding.")
    end
  end

  defp empty_ticket_types?(ticket_types, users) do
    if Enum.empty?(ticket_types) do
      Mix.shell().error("No main ticket types found. Please run ticket types seed first.")
    else
      users
      |> Enum.with_index()
      |> Enum.each(fn {user, index} ->
        ticket_type = Enum.at(ticket_types, rem(index, length(ticket_types)))

        insert_ticket(%{
          user_id: user.id,
          ticket_type_id: ticket_type.id,
          intended_transport_to_enei: "by_feet",
          diet: "vegan",
          allergens: "none",
          tshirt_size: "XL",
          paid: rem(index, 3) != 0
        })
      end)
    end
  end

  defp insert_ticket(attrs) do
    case Tickets.create_ticket(attrs) do
      {:ok, _ticket} -> nil
      {:error, changeset} -> Mix.shell().error("Failed to insert ticket for user #{attrs.user_id}: #{inspect(changeset.errors)}")
    end
  end

  defp seed_payments do
    case Repo.all(Pearl.Billing.Payment) do
      [] ->
        tickets = Repo.all(from t in Ticket, where: t.paid == true, preload: :ticket_type)

        if Enum.empty?(tickets) do
          Mix.shell().error("No paid tickets found. Please create tickets first.")
        else
          Enum.each(tickets, fn ticket ->
            insert_payment(%{
              order_id: "ORDER-#{ticket.id |> String.slice(0..7) |> String.upcase()}",
              amount: ticket.ticket_type.price,
              status: :completed,
              ticket_id: ticket.id
            })
          end)

          Mix.shell().info("Seeded #{length(tickets)} payments successfully.")
        end

      _ ->
        Mix.shell().info("Found payments, skipping seeding.")
    end
  end

  defp insert_payment(attrs) do
    case Billing.create_payment(attrs) do
      {:ok, _payment} ->
        Mix.shell().info("Created payment: #{attrs.order_id}")
        nil

      {:error, changeset} ->
        Mix.shell().error("Failed to insert payment for ticket #{attrs.ticket_id}: #{inspect(changeset.errors)}")
    end
  end

  defp seed_activity_tickets do
    case Repo.all(Pearl.Activities.ActivityTicket) do
      [] ->
        activity_ticket_types = Repo.all(from t in TicketType, where: t.type == :activity)
        users = Repo.all(from u in User, where: u.type == :attendee, limit: 20)

        cond do
          Enum.empty?(activity_ticket_types) ->
            Mix.shell().error("No activity ticket types found.")
          Enum.empty?(users) ->
            Mix.shell().error("No attendee users found. Please create users first.")
          true ->
            seed_activity_tickets_for_users(users, activity_ticket_types)
            Mix.shell().info("Seeded activity tickets successfully.")
        end

      _ ->
        Mix.shell().info("Found activity tickets, skipping seeding.")
    end
  end

  defp seed_activity_tickets_for_users(users, activity_ticket_types) do
    users
    |> Enum.with_index()
    |> Enum.each(fn {user, user_idx} ->
      activity_ticket_types
      |> Enum.with_index()
      |> Enum.each(fn {ticket_type, tt_idx} ->
        insert_activity_ticket(%{
          user_id: user.id,
          ticket_type_id: ticket_type.id,
          paid: rem(user_idx + tt_idx, 3) != 0
        })
      end)
    end)
  end

    defp insert_activity_ticket(other) do
    Mix.shell().error("[BUG] insert_activity_ticket/1 called with unexpected input: #{inspect(other)}")
    nil
  end

  defp insert_activity_ticket(attrs) do
    case Pearl.Activities.create_activity_ticket(attrs) do
      {:ok, _} -> nil
      {:error, changeset} ->
        Mix.shell().error("Failed to insert activity ticket for user #{attrs.user_id}: #{inspect(changeset.errors)}")
    end
  end
end

Pearl.Repo.Seeds.Tickets.run()
