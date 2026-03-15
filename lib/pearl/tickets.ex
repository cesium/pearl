defmodule Pearl.Tickets do
  @moduledoc """
  The Tickets context.
  """
  use Pearl.Context

  import Ecto.Query, warn: false
  alias Pearl.Repo

  alias Pearl.Tickets.{Perk, Ticket}
  alias Pearl.TicketTypes

  @doc """
  Returns the list of tickets.

  ## Examples

      iex> list_tickets()
      [%Ticket{}, ...]

  """
  def list_tickets do
    Ticket
    |> Repo.all()
    |> Repo.preload(user: :attendee)
  end

  def list_tickets(opts) when is_list(opts) do
    Ticket
    |> apply_filters(opts)
    |> Repo.all()
    |> Repo.preload(user: :attendee)
  end

  def list_tickets(params) do
    Ticket
    |> join(:left, [t], u in assoc(t, :user), as: :user)
    |> join(:left, [t], tt in assoc(t, :ticket_type), as: :ticket_type)
    |> preload([user: u, ticket_type: tt], user: {u, [:attendee]}, ticket_type: tt)
    |> Flop.validate_and_run(params, for: Ticket)
  end

  def list_tickets(%{} = params, opts) when is_list(opts) do
    Ticket
    |> apply_filters(opts)
    |> Repo.preload(user: :attendee)
    |> Flop.validate_and_run(params, for: Ticket)
  end

  @doc """
  Returns the count of tickets.

  ## Examples

      iex> count_tickets()
      3
  """
  def count_tickets do
    Ticket
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Returns the count of paid tickets.

  ## Examples

      iex> count_paid_tickets()
      1
  """
  def count_paid_tickets do
    Ticket
    |> where(paid: true)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Returns the count of pending (not paid) tickets.

  ## Examples

      iex> count_pending_tickets()
      2
  """
  def count_pending_tickets do
    Ticket
    |> where(paid: false)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
    Returns a map with the ticket type name and the count for the type.

  ## Examples

    iex> count_by_ticket_type
    %{
      "Passe Geral" => 14,
      "Passe Geral com Refeições" => 2,
      "Passe Geral com Refeições e Alojamento da Universidade do Minho" => 5
    }
  """
  def count_by_ticket_type do
    Ticket
    |> join(:inner, [t], tt in assoc(t, :ticket_type))
    |> group_by([t, tt], [tt.name, t.paid])
    |> select([t, tt], {tt.name, t.paid, count(t.id)})
    |> Repo.all()
  end

  @doc """
    Returns a map with the paid tickets grouped by ticket type name and the count for the type.

  ## Examples

    iex> count_by_ticket_type
    %{
      "Passe Geral" => 14,
      "Passe Geral com Refeições" => 2,
      "Passe Geral com Refeições e Alojamento da Universidade do Minho" => 5
    }
  """
  def count_paid_by_ticket_type do
    Ticket
    |> join(:inner, [t], tt in assoc(t, :ticket_type))
    |> where([t], t.paid == true)
    |> group_by([_t, tt], tt.name)
    |> select([t, tt], {tt.name, count(t.id)})
    |> Repo.all()
    |> Enum.into(%{})
  end

  @doc """
    Returns a map with the pending (not paid) tickets grouped by ticket type name and the count for the type.

  ## Examples

    iex> count_by_ticket_type
    %{
      "Passe Geral" => 14,
      "Passe Geral com Refeições" => 2,
      "Passe Geral com Refeições e Alojamento da Universidade do Minho" => 5
    }
  """
  def count_pending_by_ticket_type do
    Ticket
    |> join(:inner, [t], tt in assoc(t, :ticket_type))
    |> where([t], t.paid == false)
    |> group_by([_t, tt], tt.name)
    |> select([t, tt], {tt.name, count(t.id)})
    |> Repo.all()
    |> Enum.into(%{})
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

  def get_user_ticket(user_id) do
    Ticket
    |> where([t], t.user_id == ^user_id)
    |> preload([:user, :ticket_type, :payment])
    |> Repo.one()
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
    active_ticket_types = TicketTypes.list_active_ticket_types()
    current_ticket_type = attrs["ticket_type_id"] || attrs[:ticket_type_id]

    case Enum.find(active_ticket_types, fn tt -> tt.id == current_ticket_type end) do
      nil ->
        changeset =
          %Ticket{}
          |> Ticket.changeset(attrs)
          |> Ecto.Changeset.add_error(:ticket_type_id, "is not active")

        {:error, changeset}

      _ ->
        %Ticket{}
        |> Ticket.changeset(attrs)
        |> Repo.insert()
    end
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

  def mark_ticket_as_paid(%Ticket{} = ticket) do
    update_ticket(ticket, %{paid: true})
  end

  @doc """
  Returns the list of perks.

  ## Examples

      iex> list_perks()
      [%Perk{}, ...]

  """
  def list_perks do
    Perk
    |> order_by(:priority)
    |> Repo.all()
  end

  @doc """
  Gets a single perk.

  Raises `Ecto.NoResultsError` if the Perk does not exist.

  ## Examples

      iex> get_perk!(123)
      %Perk{}

      iex> get_perk!(456)
      ** (Ecto.NoResultsError)

  """
  def get_perk!(id), do: Repo.get!(Perk, id)

  @doc """
  Creates a perk.

  ## Examples

      iex> create_perk(%{field: value})
      {:ok, %Perk{}}

      iex> create_perk(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_perk(attrs) do
    %Perk{}
    |> Perk.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a perk.

  ## Examples

      iex> update_perk(perk, %{field: new_value})
      {:ok, %Perk{}}

      iex> update_perk(perk, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_perk(%Perk{} = perk, attrs) do
    perk
    |> Perk.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a perk.

  ## Examples

      iex> delete_perk(perk)
      {:ok, %Perk{}}

      iex> delete_perk(perk)
      {:error, %Ecto.Changeset{}}

  """
  def delete_perk(%Perk{} = perk) do
    Repo.delete(perk)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking perk changes.

  ## Examples

      iex> change_perk(perk)
      %Ecto.Changeset{data: %Perk{}}

  """
  def change_perk(%Perk{} = perk, attrs \\ %{}) do
    Perk.changeset(perk, attrs)
  end

  @doc """
  Returns the next priority a perk should have.

  ## Examples

      iex> get_next_perk_priority()
      5
  """
  def get_next_perk_priority do
    (Repo.aggregate(from(t in Perk), :max, :priority) || -1) + 1
  end

  def change_ticket_type(%Ticket{} = ticket, attrs \\ %{}) do
    Ticket.changeset_ticket_type(ticket, attrs)
  end

  def change_precautions(%Ticket{} = ticket, attrs \\ %{}) do
    Ticket.changeset_precautions(ticket, attrs)
  end

  def change_informations(%Ticket{} = ticket, attrs \\ %{}) do
    Ticket.changeset_informations(ticket, attrs)
  end
end
