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
    TicketType
    |> order_by(:priority)
    |> Repo.all()
  end

  @doc """
  Returns the list of active ticket_types.

  ## Examples

    iex> list_active_ticket_types()
    [%TicketType{}, ...]

  """

  def list_active_ticket_types do
    TicketType
    |> where([t], t.active == true)
    |> order_by(:priority)
    |> Repo.all()
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
    Repo.get!(TicketType, id)
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
  Archives a ticket type.

      iex> archive_ticket_type(ticket_type)
      {:ok, %TicketType{}}

      iex> archive_ticket_type(ticket_type)
      {:error, %Ecto.Changeset{}}
  """
  def archive_ticket_type(%TicketType{} = ticket_type) do
    ticket_type
    |> TicketType.changeset(%{active: false})
    |> Repo.update()
  end

  @doc """
  Unarchives a ticket type.

      iex> unarchive_ticket_type(ticket_type)
      {:ok, %TicketType{}}

      iex> unarchive_ticket_type(ticket_type)
      {:error, %Ecto.Changeset{}}
  """
  def unarchive_ticket_type(%TicketType{} = ticket_type) do
    ticket_type
    |> TicketType.changeset(%{active: true})
    |> Repo.update()
  end

  @doc """
  Returns the next priority a ticket type should have.

  ## Examples

      iex> get_next_ticket_type_priority()
      5
  """
  def get_next_ticket_type_priority do
    (Repo.aggregate(from(t in TicketType), :max, :priority) || -1) + 1
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
