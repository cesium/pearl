defmodule Pearl.Repo.Seeds.Tickets do
  import Ecto.Query

  alias Pearl.Accounts.User
  alias Pearl.{Perks, Repo, Tickets, TicketTypes}
  alias Pearl.Tickets.{Perk, Ticket, TicketType}

  @perks [
    %{name: "Entry", description: "Entrada nos 4 dias do evento", icon: "fa-ticket-solid", color: "#D93044", active: true, priority: 0},
    %{name: "Meals", description: "Refeições durante todo o evento", icon: "fa-utensils-solid", color: "#F18F01", active: true, priority: 1},
    %{name: "Accommodation", description: "Estadia no Pavilhão", icon: "fa-bed-solid", color: "#2E86AB", active: true, priority: 2},
  ]

  @ticket_types [
    %{name: "Passe Geral", description: "A nice ticket", price: 32, active: true, product_key: "b757d845-bbcd-4c10-ad6f-4effe3406a3c", priority: 0, perks: ["Entry"]},
    %{name: "Passe Geral com Refeições", description: "A much nicer ticket", price: 33, active: true, product_key: "021743b2-6ff1-4666-b70c-977c303a5da1", priority: 1, perks: ["Entry", "Meals"]},
    %{name: "Passe Geral com Refeições e Alojamento da Universidade do Minho", description: "An awesome ticket", price: 38, active: true, product_key: "0ff1e663-481a-4e42-9a52-a4ac02b72437", priority: 2, perks: ["Entry", "Meals", "Accommodation"]},
  ]

  def run do
    seed_perks()
    seed_ticket_types()
    seed_tickets()
  end

  defp seed_perks do
    case Repo.all(Perk) do
      [] ->
        Enum.each(@perks, &insert_perk/1)
        Mix.shell().info("Seeded perks successfully.")

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
    case Repo.all(TicketType) do
      [] ->
        Enum.each(@ticket_types, &insert_ticket_type/1)
        Mix.shell().info("Seeded ticket types successfully.")

      _ ->
        Mix.shell().info("Found ticket types, skipping seeding.")
    end
  end

  defp insert_ticket_type(attrs) do
    {perk_names, ticket_type_attrs} = Map.pop(attrs, :perks, [])

    case TicketTypes.create_ticket_type(ticket_type_attrs) do
      {:ok, ticket_type} ->
        perk_ids =
          Repo.all(from p in Perk, where: p.name in ^perk_names, select: p.id)

        case TicketTypes.upsert_ticket_type_perks(ticket_type, perk_ids) do
          {:ok, _ticket_type} ->
            nil

          {:error, _changeset} ->
            Mix.shell().error("Failed to associate perks for ticket type: #{attrs.name}")
        end

      {:error, _changeset} ->
        Mix.shell().error("Failed to insert ticket type: #{attrs.name}")
    end
  end

  defp seed_tickets do
    case Repo.all(Ticket) do
      [] ->
        users = Repo.all(from u in User, where: u.type == :attendee, limit: 20)

        if Enum.empty?(users) do
          Mix.shell().error("No attendee users found. Please create users first.")
        else
          ticket_types = Repo.all(TicketType)

          empty_ticket_types?(ticket_types, users)
        end

      _ ->
        Mix.shell().info("Found tickets, skipping seeding.")
    end
  end

  defp empty_ticket_types?(ticket_types, users) do
    if Enum.empty?(ticket_types) do
      Mix.shell().error("No ticket types found. Please run ticket types seed first.")
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
      {:ok, _ticket} ->
        nil

      {:error, changeset} ->
        Mix.shell().error("Failed to insert ticket for user #{attrs.user_id}: #{inspect(changeset.errors)}")
    end
  end
end

Pearl.Repo.Seeds.Tickets.run()
