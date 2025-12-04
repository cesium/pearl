defmodule Pearl.Perks do
  @moduledoc """
    Context for Perks
  """
  use Pearl.Context
  alias Pearl.Tickets.Perk

  def list_perks do
    Repo.all(Perk)
  end

  def get_perk!(id) do
    Perk
    |> Repo.get!(id)
  end

  def create_perk(attrs \\ %{}) do
    %Perk{}
    |> Perk.changeset(attrs)
    |> Repo.insert()
  end

  def change_perk(%Perk{} = perk, attrs \\ %{}) do
    Perk.changeset(perk, attrs)
  end

  def update_perk(%Perk{} = perk, attrs) do
    perk
    |> Perk.changeset(attrs)
    |> Repo.update()
  end

  def archive_perk(%Perk{} = perk) do
    perk
    |> Perk.changeset(%{active: false})
    |> Repo.update()
  end

  def unarchive_perk(%Perk{} = perk) do
    perk
    |> Perk.changeset(%{active: true})
    |> Repo.update()
  end
end
