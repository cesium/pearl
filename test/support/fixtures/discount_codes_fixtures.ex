defmodule Pearl.DiscountCodesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pearl.DiscountCodes` context.
  """

  @doc """
  Generate a discount_code.
  """
  def discount_code_fixture(attrs \\ %{}) do
    {:ok, discount_code} =
      attrs
      |> Enum.into(%{
        active: true,
        amount: 42,
        code: "some code"
      })
      |> Pearl.DiscountCodes.create_discount_code()

    discount_code
  end
end
