defmodule Pearl.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pearl.Inventory` context.
  """

  alias Pearl.AccountsFixtures

  @doc """
  Generate an item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        type: :prize,
        redeemed: true,
        redeemed_at: ~N[2024-09-15 21:18:00],
        attendee_id: AccountsFixtures.attendee_fixture().id
      })
      |> Pearl.Inventory.create_item()

    item
  end
end
