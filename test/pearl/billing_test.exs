defmodule Pearl.BillingTest do
  use Pearl.DataCase

  alias Pearl.Billing

  describe "payments" do
    alias Pearl.Billing.Payment

    import Pearl.BillingFixtures
    import Pearl.AccountsFixtures

    @invalid_attrs %{status: nil, amount: nil, order_id: nil}

    defp create_ticket_for_test do
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
          ticket_type_id: ticket_type.id,
          allergens: "none",
          tshirt_size: "m",
          diet: "omnivore"
        })

      ticket
    end

    test "list_payments/0 returns all payments" do
      payment = payment_fixture()
      assert payment in Billing.list_payments()
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = payment_fixture()
      assert Billing.get_payment!(payment.id) == payment
    end

    test "create_payment/1 with valid data creates a payment" do
      ticket = create_ticket_for_test()

      valid_attrs = %{
        status: :pending,
        amount: "120.5",
        order_id: "some order_id",
        ticket_id: ticket.id
      }

      assert {:ok, %Payment{} = payment} = Billing.create_payment(valid_attrs)
      assert payment.status == :pending
      assert payment.amount == Decimal.new("120.5")
      assert payment.order_id == "some order_id"
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Billing.create_payment(@invalid_attrs)
    end

    test "update_payment/2 with valid data updates the payment" do
      payment = payment_fixture()
      update_attrs = %{status: :completed, amount: "456.7", order_id: "some updated order_id"}

      assert {:ok, %Payment{} = payment} = Billing.update_payment(payment, update_attrs)
      assert payment.status == :completed
      assert payment.amount == Decimal.new("456.7")
      assert payment.order_id == "some updated order_id"
    end

    test "update_payment/2 with invalid data returns error changeset" do
      payment = payment_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.update_payment(payment, @invalid_attrs)
      assert payment == Billing.get_payment!(payment.id)
    end

    test "delete_payment/1 deletes the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{}} = Billing.delete_payment(payment)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_payment!(payment.id) end
    end

    test "change_payment/1 returns a payment changeset" do
      payment = payment_fixture()
      assert %Ecto.Changeset{} = Billing.change_payment(payment)
    end
  end
end
