defmodule Pearl.TicketsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pearl.Tickets` context.
  """

  @doc """
  Generate a perk.
  """
  def perk_fixture(attrs \\ %{}) do
    {:ok, perk} =
      attrs
      |> Enum.into(%{
        color: "some color",
        description: "some description",
        icon: "some icon",
        name: "some name",
        priority: "1",
        active: true
      })
      |> Pearl.Tickets.create_perk()

    perk
  end
end
