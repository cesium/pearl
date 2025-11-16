defmodule Pearl.SpotlightsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pearl.Spotlights` context.
  """

  alias Pearl.CompaniesFixtures

  @doc """
  Generate a spotlight.
  """
  def spotlight_fixture do
    {:ok, spotlight} = Pearl.Spotlights.create_spotlight(CompaniesFixtures.company_fixture().id)
    spotlight
  end
end
