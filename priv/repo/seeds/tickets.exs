defmodule Pearl.Repo.Seeds.Tickets do
  import Ecto.Query

  alias Pearl.Accounts.User
  alias Pearl.{Repo, Tickets, TicketTypes}
  alias Pearl.Tickets.{Ticket, TicketType}

  @ticket_types [
    %{name: "Normal", price: 2500, description: "Normal ticket", active: true, priotity: 0},
    %{name: "FullPass", price: 1500, description: "Premium access", active: true, priority: 1},
    %{name: "FullPass+Hotel", price: 5000, description: "Premium access with hotel", active: true, priority: 2},
    %{name: "Student", price: 3000, description: "Discounted ticket for students", active: true, priority: 3},
    %{name: "Early Bird", price: 2000, description: "Discounted early registration", active: true, priority: 4}
  ]

  def run do
    seed_ticket_types()
    seed_tickets()
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
    case TicketTypes.create_ticket_type(attrs) do
      {:ok, _ticket_type} ->
        nil

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

         empty_ticket_types?(ticket_types)
        end

      _ ->
        Mix.shell().info("Found tickets, skipping seeding.")
    end
  end

  defp empty_ticket_types?(ticket_types) do
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
