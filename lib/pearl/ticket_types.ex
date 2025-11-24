defmodule Pearl.TicketTypes do
  @moduledoc """
  The Ticket Types context
  """
  use Pearl.Context

  import Ecto.Query, warn: false
  alias Pearl.Repo

  alias Pearl.Tickets.TicketType

  @doc """
  Returns the list of ticket types.

  ## Examples

      iex> list_ticket_types()
      [%TicketType{}, ...]

  """
  def list_ticket_types do
    Repo.all(TicketType)
  end


  @doc """
  Gets a single ticket type.

  Raises `Ecto.NoResultsError` if the TicketType does not exist.

  ## Examples

      iex> get_ticket_type!(123)
      %TicketType{}

      iex> get_ticket_type!(321)
      ** (Ecto.NoResultsError)

  """

  def get_ticket_type!(id) do
    TicketType
    |> Repo.get!(id)
  end

  @doc """
  Creates a ticket type.

  ## Examples

      iex> create_ticket_type(%{field: value})
      {:ok, %TicketType{}}

      iex> create_ticket_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket_type(attrs \\ %{}) do
    %TicketType{}
    |> TicketType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticket type.

  ## Examples

      iex> update_ticket_type(ticket_type, %{field: new_value})
      {:ok, %TicketType{}}

      iex> update_ticket_type(ticket_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket_type(%TicketType{} = ticket_type, attrs) do
    ticket_type
    |> TicketType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ticket type.

  ## Examples

      iex> delete_ticket_type(ticket_type)
      {:ok, %TicketType{}}

      iex> delete_ticket_type(ticket_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket_type(%TicketType{} = ticket_type) do
    Repo.delete(ticket_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket types changes.

  ## Examples

      iex> change_ticket_type(ticket_type)
      %Ecto.Changeset{data: %TicketType{}}

  """
  def change_ticket_type(%TicketType{} = ticket_type, attrs \\ %{}) do
    TicketType.changeset(ticket_type, attrs)
  end

end
