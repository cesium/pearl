defmodule Pearl.BillingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pearl.Billing` context.
  """

  import Pearl.AccountsFixtures

  @doc """
  Generate a payment.
  """
  def payment_fixture(attrs \\ %{}) do
    ticket_id =
      attrs[:ticket_id] || create_ticket_for_payment().id

    {:ok, payment} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        order_id: "some order_id",
        status: :pending,
        ticket_id: ticket_id
      })
      |> Pearl.Billing.create_payment()

    payment
  end

  defp create_ticket_for_payment do
    user = user_fixture()

    {:ok, ticket_type} =
      Pearl.TicketTypes.create_ticket_type(%{
        name: "Test Ticket Type",
        priority: 1,
        price: 120.5,
        active: true,
        product_key: Ecto.UUID.generate()
      })

    {:ok, ticket} =
      Pearl.Tickets.create_ticket(%{
        user_id: user.id,
        ticket_type_id: ticket_type.id
      })

    ticket
  end
end
