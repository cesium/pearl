defmodule Pearl.LockersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pearl.Lockers` context.
  """

  alias Pearl.AccountsFixtures

  @doc """
  Generate a locker.
  """
  def locker_fixture(attrs \\ %{}) do
    {:ok, locker} =
      attrs
      |> Enum.into(%{
        number: System.unique_integer([:positive])
      })
      |> Pearl.Lockers.create_locker()

    locker
  end

  @doc """
  Generate a locker_item.
  """
  def locker_item_fixture(attrs \\ %{}) do
    attendee_locker_id = attendee_locker_fixture().id

    {:ok, locker_item} =
      attrs
      |> Enum.into(%{
        attendee_locker_id: attendee_locker_id,
        description: "some description",
        name: "some name",
        stored: true,
        withdrawn_at: ~U[2026-04-02 23:33:00Z]
      })
      |> Pearl.Lockers.create_locker_item()

    locker_item
  end

  @doc """
  Generate a attendee_locker.
  """
  def attendee_locker_fixture(attrs \\ %{}) do
    attendee_id = AccountsFixtures.attendee_fixture().id
    locker_id = locker_fixture().id

    {:ok, attendee_locker} =
      attrs
      |> Enum.into(%{
        active: true,
        attendee_id: attendee_id,
        locker_id: locker_id
      })
      |> Pearl.Lockers.create_attendee_locker()

    attendee_locker
  end
end
