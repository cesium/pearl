defmodule Pearl.Tickets do
  @moduledoc """
  The Tickets context.
  """
  use Pearl.Context

  import Ecto.Query, warn: false
  alias Pearl.Repo

  alias Pearl.Tickets.Ticket

  @doc """
  Returns the list of tickets.

  ## Examples

      iex> list_tickets()
      [%Ticket{}, ...]

  """
  def list_tickets do
    Ticket
    |> Repo.all()
  end

  def list_tickets(opts) when is_list(opts) do
    Ticket
    |> apply_filters(opts)
    |> Repo.all()
  end

  def list_tickets(params) do
    Ticket
    |> join(:left, [t], u in assoc(t, :user), as: :user)
    |> join(:left, [t], tt in assoc(t, :ticket_type), as: :ticket_type)
    |> preload([user: u, ticket_type: tt], user: u, ticket_type: tt)
    |> Flop.validate_and_run(params, for: Ticket)
  end

  def list_tickets(%{} = params, opts) when is_list(opts) do
    Ticket
    |> apply_filters(opts)
    |> Flop.validate_and_run(params, for: Ticket)
  end

  @doc """
  Gets a single ticket.

  Raises `Ecto.NoResultsError` if the Ticket does not exist.

  ## Examples

      iex> get_ticket!(123)
      %Ticket{}

      iex> get_ticket!(321)
      ** (Ecto.NoResultsError)

  """

  def get_ticket!(id) do
    Ticket
    |> preload([:user, :ticket_type])
    |> Repo.get!(id)
  end

  @doc """
  Creates a ticket.

  ## Examples

      iex> create_ticket(%{field: value})
      {:ok, %Ticket{}}

      iex> create_ticket(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket(attrs \\ %{}) do
    %Ticket{}
    |> Ticket.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticket.

  ## Examples

      iex> update_ticket(ticket, %{field: new_value})
      {:ok, %Ticket{}}

      iex> update_ticket(ticket, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket(%Ticket{} = ticket, attrs) do
    ticket
    |> Ticket.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ticket.

  ## Examples

      iex> delete_ticket(ticket)
      {:ok, %Ticket{}}

      iex> delete_ticket(ticket)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket(%Ticket{} = ticket) do
    Repo.delete(ticket)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket changes.

  ## Examples

      iex> change_ticket(ticket)
      %Ecto.Changeset{data: %Ticket{}}

  """
  def change_ticket(%Ticket{} = ticket, attrs \\ %{}) do
    Ticket.changeset(ticket, attrs)
  end
end
