defmodule Pearl.Repo.Seeds.Tickets do
  import Ecto.Query

  alias Pearl.Accounts.User
  alias Pearl.{Perks, Repo, Tickets, TicketTypes}
  alias Pearl.Tickets.{Perk, Ticket, TicketType}

  @perks [
    %{name: "Entry", description: "Entrada nos 4 dias do evento", icon: "hero-ticket", color: "#F9808D", active: true},
    %{name: "Meals", description: "Refeições durante todo o evento", icon: "hero-beaker", color: "#505936", active: true},
    %{name: "Accommodation", description: "Estadia no Pavilhão", icon: "hero-star", color: "#9AB7C1", active: true},
    %{name: "Premium Accommodation", description: "Estadia na Pousada da Juventude", icon: "hero-gift", color: "#D89ED0", active: true}
  ]

  @ticket_types [
    %{name: "Bilhete 1", description: "A nice ticket", price: 32, active: true, product_key: "bdd2c21a-215d-44a2-a515-a5bc7a94966b", priority: 0, perks: ["Entry"]},
    %{name: "Bilhete 2", description: "A much nicer ticket", price: 33, active: true, product_key: "bdd2c21a-215d-44a2-a515-a5bc7a94966b", priority: 1, perks: ["Entry", "Meals"]},
    %{name: "Bilhete 3", description: "An awesome ticket", price: 38, active: true, product_key: "bdd2c21a-215d-44a2-a515-a5bc7a94966b", priority: 2, perks: ["Entry", "Meals", "Accommodation"]},
    %{name: "Bilhete 4", description: "Absolutely magnificent ticket", price: 45, product_key: "bdd2c21a-215d-44a2-a515-a5bc7a94966b", active: true, priority: 3, perks: ["Entry", "Meals", "Premium Accommodation"]}
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
