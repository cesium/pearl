alias Pearl.Repo
alias Pearl.DiscountCodes.DiscountCode
alias Pearl.Tickets.TicketType

ticket_types = Repo.all(TicketType)

if Enum.empty?(ticket_types) do
  IO.puts("No ticket types found. Please run ticket_types seeds first.")
else
  normal = Enum.find(ticket_types, &(&1.name == "Normal"))
  fullpass = Enum.find(ticket_types, &(&1.name == "FullPass"))
  fullpass_hotel = Enum.find(ticket_types, &(&1.name == "FullPass+Hotel"))
  student = Enum.find(ticket_types, &(&1.name == "Student"))
  early_bird = Enum.find(ticket_types, &(&1.name == "Early Bird"))

  discount_codes = [
    %{
      code: "EARLYBIRD2025",
      amount: 10,
      active: true,
      ticket_type_ids: [normal, early_bird] |> Enum.reject(&is_nil/1) |> Enum.map(& &1.id)
    },
    %{
      code: "STUDENT50",
      amount: 20,
      active: true,
      ticket_type_ids: [student] |> Enum.reject(&is_nil/1) |> Enum.map(& &1.id)
    },
    %{
      code: "FULLPASS20",
      amount: 100,
      active: true,
      ticket_type_ids: [fullpass, fullpass_hotel] |> Enum.reject(&is_nil/1) |> Enum.map(& &1.id)
    },
    %{
      code: "ALLACCESS",
      amount: 100,
      active: true,
      ticket_type_ids: ticket_types |> Enum.map(& &1.id)
    },
    %{
      code: "SPONSOR25",
      amount: 100,
      active: true,
      ticket_type_ids: [normal, fullpass] |> Enum.reject(&is_nil/1) |> Enum.map(& &1.id)
    },
    %{
      code: "EXPIRED2024",
      amount: 33,
      active: false,
      ticket_type_ids: [normal] |> Enum.reject(&is_nil/1) |> Enum.map(& &1.id)
    }
  ]

  Enum.each(discount_codes, fn attrs ->
    case Repo.get_by(DiscountCode, code: attrs.code) do
      nil ->
        case Pearl.DiscountCodes.create_discount_code(attrs) do
          {:ok, _} ->
            IO.puts("Created discount code: #{attrs.code}")
          {:error, changeset} ->
            IO.puts("Failed to create discount code #{attrs.code}: #{inspect(changeset.errors)}")
        end

      existing ->
        IO.puts("Discount code already exists: #{existing.code}")
    end
  end)

  IO.puts("Discount codes seeded successfully!")
end
