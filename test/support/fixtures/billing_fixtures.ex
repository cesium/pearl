defmodule Pearl.BillingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pearl.Billing` context.
  """

  @doc """
  Generate a payment.
  """
  def payment_fixture(attrs \\ %{}) do
    {:ok, payment} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        order_id: "some order_id",
        status: "some status"
      })
      |> Pearl.Billing.create_payment()

    payment
  end
end
