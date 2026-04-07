defmodule Pearl.Lockers do
  @moduledoc """
  The Lockers context.
  """

  import Ecto.Query, warn: false
  alias Pearl.Repo

  alias Pearl.Lockers.AttendeeLocker
  alias Pearl.Lockers.Locker

  @doc """
  Returns the list of lockers.

  ## Examples

      iex> list_lockers()
      [%Locker{}, ...]

  """
  def list_lockers do
    Repo.all(Locker)
  end

  @doc """
  Returns the list of free lockers.

  ## Examples

      iex> list_free_lockers()
      [%Locker{}, ...]

  """
  def list_free_lockers do
    Locker
    |> join(:left, [l], al in AttendeeLocker, on: l.id == al.locker_id and al.active == true)
    |> where([_l, al], is_nil(al.id))
    |> order_by([l, _al], asc: l.number)
    |> Repo.all()
  end

  @doc """
  Checks if there are any lockers configured.

  ## Examples

      iex> lockers_configured?()
      true

  """
  def lockers_configured? do
    Locker
    |> Repo.exists?()
  end

  @doc """
  Returns the current ammout of lockers configured.

  ## Examples

      iex> get_current_lockers_count()
      20

  """
  def get_current_lockers_count do
    Locker
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Gets a single locker.

  Raises `Ecto.NoResultsError` if the Locker does not exist.

  ## Examples

      iex> get_locker!(123)
      %Locker{}

      iex> get_locker!(456)
      ** (Ecto.NoResultsError)

  """
  def get_locker!(id), do: Repo.get!(Locker, id)

  @doc """
  Checks if an attendee has an active locker.

  ## Examples

      iex> has_active_locker(123)
      false

      iex> has_active_locker(456)
      true

  """
  def has_active_locker(attendee_id) do
    AttendeeLocker
    |> where([al], al.attendee_id == ^attendee_id and al.active == true)
    |> Repo.exists?()
  end

  @doc """
  Gets a single active locker for a given attendee if he has one.

  ## Examples

      iex> get_active_locker(123)
      %Locker{}

      iex> get_active_locker(456)
      nil

  """
  def get_active_locker(attendee_id) do
    Locker
    |> join(:inner, [l], al in AttendeeLocker, on: al.locker_id == l.id)
    |> where([_l, al], al.attendee_id == ^attendee_id and al.active == true)
    |> Repo.one()
  end

  @doc """
  Checks if a lockers has an active session with an attendee.

  ## Examples

      iex> has_active_attendee(123)
      false

      iex> has_active_attendee(456)
      true

  """
  def has_active_attendee(locker_id) do
    AttendeeLocker
    |> where([al], al.locker_id == ^locker_id and al.active == true)
    |> Repo.exists?()
  end

  @doc """
  Creates a locker.

  ## Examples

      iex> create_locker(%{field: value})
      {:ok, %Locker{}}

      iex> create_locker(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_locker(attrs) do
    %Locker{}
    |> Locker.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Configures missing lockers up to the given maximum.

  ## Examples

      iex> configure_lockers(10)
      {:ok, [%Locker{}, ...]}

      iex> configure_lockers(5)
      {:error, :out_of_bound}

  """
  def configure_lockers(new_max) when is_integer(new_max) and new_max > 0 do
    current_count = get_current_lockers_count()

    if new_max <= current_count do
      {:error, :out_of_bound}
    else
      current_count
      |> lockers_to_create(new_max)
      |> Enum.reduce(Ecto.Multi.new(), &add_locker_to_multi/2)
      |> Repo.transaction()
      |> case do
        {:ok, lockers} ->
          {:ok,
           lockers
           |> Map.values()
           |> Enum.sort_by(& &1.number)}

        {:error, failed, changeset, successful} ->
          {:error, failed, changeset, successful}
      end
    end
  end

  defp lockers_to_create(current_count, new_max) do
    (current_count + 1)..new_max
    |> Enum.to_list()
  end

  defp add_locker_to_multi(number, multi) do
    changeset = Locker.changeset(%Locker{}, %{number: number})

    multi
    |> Ecto.Multi.insert({:locker, number}, changeset)
  end

  @doc """
  Updates a locker.

  ## Examples

      iex> update_locker(locker, %{field: new_value})
      {:ok, %Locker{}}

      iex> update_locker(locker, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_locker(%Locker{} = locker, attrs) do
    locker
    |> Locker.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a locker.

  ## Examples

      iex> delete_locker(locker)
      {:ok, %Locker{}}

      iex> delete_locker(locker)
      {:error, %Ecto.Changeset{}}

  """
  def delete_locker(%Locker{} = locker) do
    Repo.delete(locker)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking locker changes.

  ## Examples

      iex> change_locker(locker)
      %Ecto.Changeset{data: %Locker{}}

  """
  def change_locker(%Locker{} = locker, attrs \\ %{}) do
    Locker.changeset(locker, attrs)
  end

  alias Pearl.Lockers.LockerItem

  @doc """
  Returns the list of locker_items.

  ## Examples

      iex> list_locker_items()
      [%LockerItem{}, ...]

  """
  def list_locker_items do
    Repo.all(LockerItem)
  end

  @doc """
  Returns the list of locker items for a given attendee locker session.

  ## Examples

      iex> list_locker_items_by_session(12)
      [%LockerItem{}, ...]

  """
  def list_locker_items_by_session(attendee_locker_id) do
    LockerItem
    |> where([li], li.attendee_locker_id == ^attendee_locker_id)
    |> order_by([li], desc: li.inserted_at)
    |> Repo.all()
  end

  @doc """
  Checks if all locker items in a given attendee locker session are withdrawn.

  ## Examples

      iex> all_withdrawn?(12)
      false

  """
  def all_withdrawn?(attendee_locker_id) do
    session_items_query =
      LockerItem
      |> where([li], li.attendee_locker_id == ^attendee_locker_id)

    has_items? = Repo.exists?(session_items_query)

    has_stored_items? =
      session_items_query
      |> where([li], li.stored == true)
      |> Repo.exists?()

    has_items? and not has_stored_items?
  end

  @doc """
  Gets a single locker_item.

  Raises `Ecto.NoResultsError` if the Locker item does not exist.

  ## Examples

      iex> get_locker_item!(123)
      %LockerItem{}

      iex> get_locker_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_locker_item!(id), do: Repo.get!(LockerItem, id)

  @doc """
  Creates a locker_item.

  ## Examples

      iex> create_locker_item(%{field: value})
      {:ok, %LockerItem{}}

      iex> create_locker_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_locker_item(attrs) do
    %LockerItem{}
    |> LockerItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a locker_item.

  ## Examples

      iex> update_locker_item(locker_item, %{field: new_value})
      {:ok, %LockerItem{}}

      iex> update_locker_item(locker_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_locker_item(%LockerItem{} = locker_item, attrs) do
    locker_item
    |> LockerItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a locker item's picture.
  """
  def update_locker_item_picture(%LockerItem{} = locker_item, attrs) do
    locker_item
    |> LockerItem.picture_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a locker_item.

  ## Examples

      iex> delete_locker_item(locker_item)
      {:ok, %LockerItem{}}

      iex> delete_locker_item(locker_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_locker_item(%LockerItem{} = locker_item) do
    Repo.delete(locker_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking locker_item changes.

  ## Examples

      iex> change_locker_item(locker_item)
      %Ecto.Changeset{data: %LockerItem{}}

  """
  def change_locker_item(%LockerItem{} = locker_item, attrs \\ %{}) do
    LockerItem.changeset(locker_item, attrs)
  end

  alias Pearl.Lockers.AttendeeLocker

  @doc """
  Returns the list of attendee_lockers.

  ## Examples

      iex> list_attendee_lockers()
      [%AttendeeLocker{}, ...]

  """
  def list_attendee_lockers do
    Repo.all(AttendeeLocker)
  end

  @doc """
  Returns locker sessions history for a given attendee

  """
  def list_attendee_locker_history(attendee_id) do
    AttendeeLocker
    |> join(:inner, [al], l in Locker, on: l.id == al.locker_id)
    |> where([al, _l], al.attendee_id == ^attendee_id)
    |> order_by([al, _l], desc: al.inserted_at)
    |> select([al, l], %{
      id: al.id,
      locker_number: l.number,
      active: al.active,
      inserted_at: al.inserted_at,
      updated_at: al.updated_at
    })
    |> Repo.all()
  end

  @doc """
  Returns a map of attendee_id and its active locker.

  ## Examples

      iex> list_active_lockers_for_attendees(["1", "2"])
      %{"1" => 12}

  """
  def list_active_lockers_for_attendees(attendee_ids) when is_list(attendee_ids) do
    AttendeeLocker
    |> join(:inner, [al], l in Locker, on: l.id == al.locker_id)
    |> where([al, _l], al.attendee_id in ^attendee_ids and al.active == true)
    |> select([al, l], {al.attendee_id, l.number})
    |> Repo.all()
    |> Map.new()
  end

  @doc """
  Gets a single attendee_locker.

  Raises `Ecto.NoResultsError` if the Attendee locker does not exist.

  ## Examples

      iex> get_attendee_locker!(123)
      %AttendeeLocker{}

      iex> get_attendee_locker!(456)
      ** (Ecto.NoResultsError)

  """
  def get_attendee_locker!(id), do: Repo.get!(AttendeeLocker, id)

  @doc """
  Gets a single active attendee_locker session for a give attendee.

  Raises `Ecto.NoResultsError` if the Attendee locker does not exist.

  ## Examples

      iex> get_active_attendee_locker!(123)
      %AttendeeLocker{}

      iex> get_active_attendee_locker!(456)
      ** (Ecto.NoResultsError)

  """
  def get_active_attendee_locker!(attendee_id) do
    AttendeeLocker
    |> where([al], al.attendee_id == ^attendee_id and al.active == true)
    |> Repo.one!()
  end

  @doc """
  Creates a attendee_locker if neither attendee nor locker have an active session already.

  ## Examples

      iex> create_attendee_locker(%{field: value})
      {:ok, %AttendeeLocker{}}

      iex> create_attendee_locker(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_attendee_locker(%{locker_id: locker_id, attendee_id: attendee_id} = attrs)
      when not is_nil(locker_id) and not is_nil(attendee_id) do
    locker_busy? = has_active_attendee(locker_id)
    attendee_busy? = has_active_locker(attendee_id)

    cond do
      locker_busy? ->
        {:error, :locker_busy}

      attendee_busy? ->
        {:error, :attendee_busy}

      true ->
        %AttendeeLocker{}
        |> AttendeeLocker.changeset(attrs)
        |> Repo.insert()
    end
  end

  def create_attendee_locker(attrs) do
    %AttendeeLocker{}
    |> AttendeeLocker.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a attendee_locker.

  ## Examples

      iex> update_attendee_locker(attendee_locker, %{field: new_value})
      {:ok, %AttendeeLocker{}}

      iex> update_attendee_locker(attendee_locker, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_attendee_locker(%AttendeeLocker{} = attendee_locker, attrs) do
    attendee_locker
    |> AttendeeLocker.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a attendee_locker.

  ## Examples

      iex> delete_attendee_locker(attendee_locker)
      {:ok, %AttendeeLocker{}}

      iex> delete_attendee_locker(attendee_locker)
      {:error, %Ecto.Changeset{}}

  """
  def delete_attendee_locker(%AttendeeLocker{} = attendee_locker) do
    Repo.delete(attendee_locker)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking attendee_locker changes.

  ## Examples

      iex> change_attendee_locker(attendee_locker)
      %Ecto.Changeset{data: %AttendeeLocker{}}

  """
  def change_attendee_locker(%AttendeeLocker{} = attendee_locker, attrs \\ %{}) do
    AttendeeLocker.changeset(attendee_locker, attrs)
  end
end
