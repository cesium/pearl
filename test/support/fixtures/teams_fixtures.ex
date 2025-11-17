defmodule Pearl.TeamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pearl.Teams` context.
  """

  @doc """
  Generate a team.
  """

  def team_fixture(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{name: "some name", priority: 0})
      |> Pearl.Teams.create_team()

    team
  end

  @doc """
  Generate a team_member.
  """

  def team_member_fixture(attrs \\ %{}) do
    team = team_fixture()

    {:ok, team_member} =
      attrs
      |> Enum.into(%{name: "some name", team_id: team.id})
      |> Pearl.Teams.create_team_member()

    team_member
  end
end
