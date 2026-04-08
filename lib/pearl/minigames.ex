defmodule Pearl.Minigames do
  @moduledoc """
  The Minigames context.
  """

  use Pearl.Context

  alias Ecto.Multi

  alias Pearl.{Accounts, Constants, Contest}
  alias Pearl.Accounts.Attendee
  alias Pearl.Inventory.Item
  alias Pearl.Minigames.ScratchCardSymbol

  alias Pearl.Minigames.{
    CoinFlipRoom,
    HorseRaceBet,
    Prize,
    ScratchCard,
    ScratchCardDrop,
    ScratchCardSymbol,
    SlotsPayline,
    SlotsPaytable,
    SlotsReelIcon,
    WheelDrop,
    WheelSpin
  }

  @pubsub Pearl.PubSub

  @doc """
  Returns the list of prizes.

  ## Examples

      iex> list_prizes()
      [%Prize{}, ...]

  """
  def list_prizes do
    Repo.all(Prize)
  end

  def list_prizes(opts) when is_list(opts) do
    Prize
    |> apply_filters(opts)
    |> Repo.all()
  end

  def list_prizes(params) do
    Prize
    |> Flop.validate_and_run(params, for: Prize)
  end

  def list_prizes(%{} = params, opts) when is_list(opts) do
    Prize
    |> apply_filters(opts)
    |> Flop.validate_and_run(params, for: Prize)
  end

  @doc """
  Gets a single prize.

  Raises `Ecto.NoResultsError` if the Prize does not exist.

  ## Examples

      iex> get_prize!(123)
      %Prize{}

      iex> get_prize!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prize!(id), do: Repo.get!(Prize, id)

  @doc """
  Creates a prize.

  ## Examples

      iex> create_prize(%{field: value})
      {:ok, %Prize{}}

      iex> create_prize(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prize(attrs \\ %{}) do
    %Prize{}
    |> Prize.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a prize.

  ## Examples

      iex> update_prize(prize, %{field: new_value})
      {:ok, %Prize{}}

      iex> update_prize(prize, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prize(%Prize{} = prize, attrs) do
    prize
    |> Prize.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a prize image.

  ## Examples

      iex> update_prize_image(prize, %{image: image})
      {:ok, %Prize{}}

      iex> update_prize_image(prize, %{image: bad_image})
      {:error, %Ecto.Changeset{}}

  """
  def update_prize_image(%Prize{} = prize, attrs) do
    prize
    |> Prize.image_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a prize.

  ## Examples

      iex> delete_prize(prize)
      {:ok, %Prize{}}

      iex> delete_prize(prize)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prize(%Prize{} = prize) do
    Repo.delete(prize)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prize changes.

  ## Examples

      iex> change_prize(prize)
      %Ecto.Changeset{data: %Prize{}}

  """
  def change_prize(%Prize{} = prize, attrs \\ %{}) do
    Prize.changeset(prize, attrs)
  end

  @doc """
  Returns the list of wheel_drops.

  ## Examples

      iex> list_wheel_drops()
      [%WheelDrop{}, ...]

  """
  def list_wheel_drops do
    WheelDrop
    |> order_by([wd], asc: wd.probability)
    |> Repo.all()
    |> Repo.preload([:badge, :prize])
  end

  @doc """
  Gets a single wheel_drop.

  Raises `Ecto.NoResultsError` if the Wheel drop does not exist.

  ## Examples

      iex> get_wheel_drop!(123)
      %WheelDrop{}

      iex> get_wheel_drop!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wheel_drop!(id), do: Repo.get!(WheelDrop, id)

  @doc """
  Creates a wheel_drop.

  ## Examples

      iex> create_wheel_drop(%{field: value})
      {:ok, %WheelDrop{}}

      iex> create_wheel_drop(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wheel_drop(attrs \\ %{}) do
    result =
      %WheelDrop{}
      |> WheelDrop.changeset(attrs)
      |> Repo.insert()

    broadcast_wheel_config_update("drops", list_wheel_drops())
    result
  end

  @doc """
  Updates a wheel_drop.

  ## Examples

      iex> update_wheel_drop(wheel_drop, %{field: new_value})
      {:ok, %WheelDrop{}}

      iex> update_wheel_drop(wheel_drop, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wheel_drop(%WheelDrop{} = wheel_drop, attrs) do
    result =
      wheel_drop
      |> WheelDrop.changeset(attrs)
      |> Repo.update()

    broadcast_wheel_config_update("drops", list_wheel_drops())
    result
  end

  @doc """
  Deletes a wheel_drop.

  ## Examples

      iex> delete_wheel_drop(wheel_drop)
      {:ok, %WheelDrop{}}

      iex> delete_wheel_drop(wheel_drop)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wheel_drop(%WheelDrop{} = wheel_drop) do
    result = Repo.delete(wheel_drop)
    broadcast_wheel_config_update("drops", list_wheel_drops())
    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wheel_drop changes.

  ## Examples

      iex> change_wheel_drop(wheel_drop)
      %Ecto.Changeset{data: %WheelDrop{}}

  """
  def change_wheel_drop(%WheelDrop{} = wheel_drop, attrs \\ %{}) do
    WheelDrop.changeset(wheel_drop, attrs)
  end

  @doc """
  Returns the type of the wheel drop.

  ## Examples

      iex> get_drop_type(%WheelDrop{} = wheel_drop)
      :prize

  """
  def get_drop_type(drop) do
    cond do
      drop.prize_id -> :prize
      drop.badge_id -> :badge
      drop.tokens && drop.tokens != 0 -> :tokens
      drop.entries && drop.entries != 0 -> :entries
      true -> nil
    end
  end

  @doc """
  Changes the wheel spin price.

  ## Examples

      iex> set_wheel_price(20)
      :ok
  """
  def change_wheel_price(price) do
    Constants.set("wheel_spin_price", price)
    broadcast_wheel_config_update("price", price)
  end

  @doc """
  Spins the wheel for the given attendee.

  ## Examples

      iex> spin_wheel(attendee)
      {:ok, :prize, %WheelDrop{}}

      iex> spin_wheel(attendee)
      {:ok, :tokens, %WheelDrop{}}

      iex> spin_wheel(attendee)
      {:ok, nil, %WheelDrop{}}
  """
  def spin_wheel(attendee) do
    attendee = Accounts.get_attendee!(attendee.id)

    if wheel_active?() do
      case spin_wheel_transaction(attendee) do
        {:ok, result} ->
          # If the wheel spins successfully, trigger the badge event
          Contest.enqueue_badge_trigger_execution_job(attendee, :play_wheel_event)
          {:ok, get_drop_type(result.drop), result.drop}

        {:error, _} ->
          {:error, "An error occurred while spinning the wheel."}
      end
    else
      {:error, "The wheel is not active."}
    end
  end

  def wheel_latest_wins(count) do
    WheelSpin
    |> order_by([ws], desc: ws.inserted_at)
    |> limit(^count)
    |> Repo.all()
    |> Repo.preload(attendee: [:user], drop: [:prize, :badge])
  end

  defp spin_wheel_transaction(attendee) do
    Multi.new()
    # Fetch the wheel spin price
    |> Multi.put(:wheel_price, get_wheel_price())
    # Remove the wheel spin price from the attendee's token balance
    |> Multi.merge(fn %{wheel_price: price} ->
      Contest.change_attendee_tokens_transaction(attendee, attendee.tokens - price, :attendee)
    end)
    # Fetch a random drop according to the probabilities and available stock of drops with prizes
    |> Multi.run(:drop, fn _repo, %{attendee: attendee} ->
      {:ok, generate_valid_wheel_drop(attendee)}
    end)
    # Apply the reward action for the drop
    |> Multi.merge(fn %{drop: drop, attendee: attendee} ->
      drop_reward_action(drop, attendee)
    end)
    # Add record of the spin transaction to the database
    |> Multi.merge(fn %{drop: drop, attendee: attendee} ->
      add_spin_action(drop, attendee)
    end)
    |> Multi.run(:notify, fn _repo, params -> broadcast_spin_changes(params) end)
    # Execute the transaction
    |> Repo.transaction()
  end

  defp broadcast_spin_changes(params) do
    case broadcast_wheel_win(Map.get(params, :spin)) do
      :ok ->
        case broadcast_wheel_config_update("drops", list_wheel_drops()) do
          :ok -> {:ok, :ok}
          e -> e
        end

      e ->
        e
    end
  end

  defp add_spin_action(drop, attendee) do
    if is_nil(drop) or (is_nil(drop.badge_id) and is_nil(drop.prize_id)) do
      # If there was no prize, or the prize was just tokens, don't insert it
      Multi.new()
    else
      Multi.new()
      |> Multi.insert(:spin, fn _ ->
        WheelSpin.changeset(%WheelSpin{}, %{drop_id: drop.id, attendee_id: attendee.id})
      end)
    end
  end

  defp generate_valid_wheel_drop(attendee) do
    drop = generate_wheel_drop()

    case get_drop_type(drop) do
      :prize ->
        if get_attendee_prize_inventory_quantity(attendee.id, drop.prize_id) <
             drop.max_per_attendee do
          drop
        else
          # If the attendee already has maximum amount of prize, they win nothing
          %WheelDrop{}
        end

      :badge ->
        if Contest.attendee_owns_badge?(attendee.id, drop.badge_id) do
          # If the attendee already has the badge, they win nothing
          %WheelDrop{}
        else
          drop
        end

      _ ->
        drop
    end
  end

  @doc """
  Simulates a wheel spin.
  """
  def simulate_wheel_spin do
    drop = generate_wheel_drop()

    {:ok, get_drop_type(drop), drop}
  end

  defp generate_wheel_drop do
    random = strong_randomizer() |> Float.round(12)

    drops = list_available_wheel_drops()

    cumulative_probabilities =
      drops
      |> Enum.sort_by(& &1.probability)
      |> Enum.map_reduce(0, fn drop, acc ->
        {Float.round(acc + drop.probability, 12), acc + drop.probability}
      end)

    cumulatives =
      cumulative_probabilities
      |> elem(0)
      |> Enum.concat([1])

    sum =
      cumulative_probabilities
      |> elem(1)

    remaining_probability = 1 - sum

    real_drops =
      Enum.sort_by(drops, & &1.probability) ++ [%WheelDrop{probability: remaining_probability}]

    prob =
      cumulatives
      |> Enum.filter(fn x -> x >= random end)
      |> Enum.at(0)

    real_drops
    |> Enum.at(cumulatives |> Enum.find_index(fn x -> x == prob end))
  end

  defp drop_reward_action(drop, attendee) do
    case get_drop_type(drop) do
      :prize ->
        Multi.new()
        |> Multi.insert(
          :item,
          Item.changeset(%Item{}, %{
            prize_id: drop.prize_id,
            attendee_id: attendee.id,
            type: :prize
          })
        )
        |> Multi.update(
          :prize,
          Prize.update_stock_changeset(drop.prize, %{stock: drop.prize.stock - 1})
        )

      :badge ->
        Contest.redeem_badge_transaction(drop.badge, attendee)

      :tokens ->
        Contest.change_attendee_tokens_transaction(
          attendee,
          attendee.tokens + drop.tokens,
          :attendee_state_tokens,
          :previous_daily_tokens,
          :new_daily_tokens
        )

      :entries ->
        Multi.new()
        |> Multi.update(
          :attendee_state_entries,
          Attendee.update_entries_changeset(attendee, %{entries: attendee.entries + drop.entries})
        )

      nil ->
        Multi.new()
    end
  end

  defp get_attendee_prize_inventory_quantity(attendee_id, prize_id) do
    Item
    |> where([i], i.attendee_id == ^attendee_id and i.prize_id == ^prize_id)
    |> Repo.aggregate(:count)
  end

  def list_available_wheel_drops do
    WheelDrop
    |> join(:left, [wd], p in Prize, on: wd.prize_id == p.id)
    |> where([wd, p], is_nil(wd.prize_id) or p.stock > 0)
    |> preload([:prize, :badge])
    |> Repo.all()
  end

  @doc """
  Gets the wheel spin price.

  ## Examples

      iex> get_wheel_price()
      20
  """
  def get_wheel_price do
    case Constants.get("wheel_spin_price") do
      {:ok, price} ->
        price

      {:error, _} ->
        # If the price is not set, set it to 0 by default
        change_wheel_price(0)
        0
    end
  end

  @doc """
  Changes the wheel active status.

  ## Examples

      iex> change_wheel_active(true)
      :ok
  """
  def change_wheel_active(active) do
    Constants.set("wheel_active_status", active)
    broadcast_wheel_config_update("is_active", active)
  end

  @doc """
  Gets the wheel active status.

  ## Examples

      iex> wheel_active?()
      true
  """
  def wheel_active? do
    case Constants.get("wheel_active_status") do
      {:ok, active} ->
        active

      {:error, _} ->
        # If the active status is not set, set it to false by default
        change_wheel_active(true)
        true
    end
  end

  @doc """
  Subscribes the caller to the wheel's configuration updates.

  ## Examples

      iex> subscribe_to_wheel_config_update()
      :ok
  """
  def subscribe_to_wheel_config_update(config) do
    Phoenix.PubSub.subscribe(@pubsub, wheel_config_topic(config))
  end

  defp wheel_config_topic(config), do: "wheel:#{config}"

  defp broadcast_wheel_config_update(config, value) do
    Phoenix.PubSub.broadcast(@pubsub, wheel_config_topic(config), {config, value})
  end

  @doc """
  Subscribes the caller to the wheel's wins.

  ## Examples

      iex> subscribe_to_wheel_wins()
      :ok
  """
  def subscribe_to_wheel_wins do
    Phoenix.PubSub.subscribe(@pubsub, "wheel_win")
  end

  defp broadcast_wheel_win(value) do
    value = value |> Repo.preload(attendee: [:user], drop: [:prize, :badge])

    if not is_nil(value) and not is_nil(value.drop) and
         (not is_nil(value.drop.badge) or not is_nil(value.drop.prize)) do
      Phoenix.PubSub.broadcast(@pubsub, "wheel_win", {"win", value})
    else
      :ok
    end
  end

  # Generates a random number using the Erlang crypto module
  defp strong_randomizer do
    <<i1::unsigned-integer-32, i2::unsigned-integer-32, i3::unsigned-integer-32>> =
      :crypto.strong_rand_bytes(12)

    :rand.seed(:exsplus, {i1, i2, i3})
    :rand.uniform()
  end

  @doc """
  Returns the list of coin_flip_rooms.

  ## Examples

      iex> list_coin_flip_rooms()
      [%CoinFlipRoom{}, ...]

  """
  def list_coin_flip_rooms do
    CoinFlipRoom
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
    |> Repo.preload(player1: :user, player2: :user)
  end

  @doc """
  Returns the list of current active coin flip rooms, ordered by most recent first.

  ## Examples

      iex> list_current_coin_flip_rooms()
      [%CoinFlipRoom{finished: false}, ...]
  """
  def list_current_coin_flip_rooms do
    CoinFlipRoom
    |> where([r], not r.finished)
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
    |> Repo.preload(player1: :user, player2: :user)
  end

  @doc """
    Returns the list of previous (finished) coin flip rooms, ordered by most recent first.

    ## Examples

        iex> list_previous_coin_flip_rooms()
        [%CoinFlipRoom{finished: true}, ...]
        iex> list_previous_coin_flip_rooms(10)
        [%CoinFlipRoom{finished: true}, ...]
  """
  def list_previous_coin_flip_rooms(limit \\ nil) do
    query =
      CoinFlipRoom
      |> where([r], r.finished)
      |> order_by([r], desc: r.inserted_at)

    query = if limit, do: query |> limit(^limit), else: query

    query
    |> Repo.all()
    |> Repo.preload(player1: :user, player2: :user)
  end

  @doc """
  Gets a single coin_flip_room.

  Raises `Ecto.NoResultsError` if the Coin flip room does not exist.

  ## Examples

      iex> get_coin_flip_room!(123)
      %CoinFlipRoom{}

      iex> get_coin_flip_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_coin_flip_room!(id) do
    CoinFlipRoom
    |> Repo.get!(id)
    |> Repo.preload(player1: :user, player2: :user)
  end

  defp create_coin_flip_room_transaction(attendee, bet) do
    Multi.new()
    # Fetch the room play cost
    |> Multi.put(:bet, bet)
    # Remove the room play cost from the attendee's token balance
    |> Multi.merge(fn %{bet: bet} ->
      Contest.change_attendee_tokens_transaction(attendee, attendee.tokens - bet, :attendee)
    end)
    # Create the coin flip room
    |> Multi.run(:coin_flip_room, fn _repo, %{attendee: attendee} ->
      attrs = %{
        player1_id: attendee.id,
        bet: bet
      }

      %CoinFlipRoom{}
      |> CoinFlipRoom.changeset(attrs)
      |> Repo.insert()
    end)
    # Execute the transaction
    |> Repo.transaction()
  end

  @doc """
  Creates a coin_flip_room.

  ## Examples

      iex> create_coin_flip_room(%{field: value})
      {:ok, %CoinFlipRoom{}}

      iex> create_coin_flip_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_coin_flip_room(attrs \\ %{}) do
    attendee = Accounts.get_attendee!(attrs["attendee_id"])

    cond do
      not coin_flip_active?() ->
        {:error, "The coin flip game is not active."}

      has_active_coin_flip_game?(attendee.id) ->
        {:error, "You already have an active game."}

      attrs["bet"] <= 0 ->
        {:error, "The bet amount must be greater than 0."}

      true ->
        case create_coin_flip_room_transaction(attendee, attrs["bet"]) do
          {:ok, result} ->
            coin_flip_room = Repo.preload(result.coin_flip_room, player1: :user)
            broadcast_coin_flip_rooms_update("create", coin_flip_room)
            {:ok, coin_flip_room}

          {:error, _, changeset, _} ->
            {:error, changeset}
        end
    end
  end

  @doc """
  Updates a coin_flip_room.

  ## Examples

      iex> update_coin_flip_room(coin_flip_room, %{field: new_value})
      %CoinFlipRoom{}

  """
  def update_coin_flip_room(%CoinFlipRoom{} = coin_flip_room, attrs) do
    changeset = CoinFlipRoom.changeset(coin_flip_room, attrs)

    case Repo.update(changeset) do
      {:ok, coin_flip_room} ->
        {:ok, coin_flip_room}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp delete_coin_flip_room_transaction(room) do
    Multi.new()
    |> Multi.merge(fn _changes ->
      Contest.change_attendee_tokens_transaction(
        room.player1,
        room.player1.tokens + room.bet,
        :player1
      )
    end)
    |> Multi.delete(:coin_flip_room, room)
    |> Repo.transaction()
  end

  @doc """
  Deletes a coin_flip_room.

  ## Examples

      iex> delete_coin_flip_room(coin_flip_room)
      {:ok, %CoinFlipRoom{}}

      iex> delete_coin_flip_room(coin_flip_room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_coin_flip_room(%CoinFlipRoom{} = coin_flip_room) do
    if coin_flip_room.finished do
      {:error, "The room is already finished."}
    else
      case delete_coin_flip_room_transaction(coin_flip_room) do
        {:ok, _} ->
          broadcast_coin_flip_rooms_update("delete", coin_flip_room)
          {:ok, coin_flip_room}

        {:error, changeset} ->
          {:error, changeset}
      end
    end
  end

  @doc """
  Checks if an attendee has an active (unfinished) coin flip game.

  Takes an attendee id and checks if they are either player1 or player2 in any unfinished coin flip room.

  ## Parameters
    * `attendee_id` - The id of the attendee to check

  ## Returns
    * `true` - If the attendee has an active game
    * `false` - If the attendee has no active games

  ## Examples

      iex> has_active_coin_flip_game?(123)
      true

      iex> has_active_coin_flip_game?(456)
      false
  """
  def has_active_coin_flip_game?(attendee_id) do
    CoinFlipRoom
    |> where([r], not r.finished)
    |> where([r], r.player1_id == ^attendee_id or r.player2_id == ^attendee_id)
    |> Repo.exists?()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking coin_flip_room changes.

  ## Examples

      iex> change_coin_flip_room(coin_flip_room)
      %Ecto.Changeset{data: %CoinFlipRoom{}}

  """
  def change_coin_flip_room(%CoinFlipRoom{} = coin_flip_room, attrs \\ %{}) do
    CoinFlipRoom.changeset(coin_flip_room, attrs)
  end

  @doc """
  Changes the coin flip fee.

  ## Examples

      iex> set_coin_flip_fee(20)
      :ok
  """
  def change_coin_flip_fee(fee) do
    Constants.set("coin_flip_fee", fee)
    broadcast_coin_flip_config_update("fee", fee)
  end

  @doc """
  Gets the coin flip fee.

  ## Examples

      iex> get_coin_flip_fee()
      20
  """
  def get_coin_flip_fee do
    case Constants.get("coin_flip_fee") do
      {:ok, fee} ->
        fee

      {:error, _} ->
        # If the fee is not set, set it to 0 by default
        change_coin_flip_fee(0)
        0
    end
  end

  @doc """
  Changes the coin flip active status.

  ## Examples

      iex> change_coin_flip_active(true)
      :ok
  """
  def change_coin_flip_active(active) do
    Constants.set("coin_flip_active_status", active)
    broadcast_coin_flip_config_update("is_active", active)
  end

  @doc """
  Gets the coin flip active status.

  ## Examples

      iex> coin_flip_active?()
      true
  """
  def coin_flip_active? do
    case Constants.get("coin_flip_active_status") do
      {:ok, active} ->
        active

      {:error, _} ->
        # If the active status is not set, set it to false by default
        change_coin_flip_active(true)
        true
    end
  end

  defp join_coin_flip_room_transaction(room, attendee_id) do
    attendee = Accounts.get_attendee!(attendee_id)

    Multi.new()
    # Remove the room play cost from player2's balance
    |> Multi.merge(fn _changes ->
      Contest.change_attendee_tokens_transaction(attendee, attendee.tokens - room.bet, :player2)
    end)
    # Flip the coin and update the room
    |> Multi.run(:coin_flip_room, fn repo, _changes ->
      result = flip_coin()

      room
      |> CoinFlipRoom.changeset(%{
        player2_id: attendee_id,
        result: result,
        finished: true
      })
      |> repo.update()
    end)
    # Award tokens to winner
    |> Multi.merge(fn %{coin_flip_room: updated_room, player2: player2} ->
      updated_room = Repo.preload(updated_room, [:player1, :player2])
      winner = if updated_room.result == "tails", do: player2, else: updated_room.player1

      fee =
        case Constants.get("coin_flip_fee") do
          {:ok, fee} -> fee
          {:error, _} -> 0
        end

      winnings = floor(room.bet * 2 * (1 - fee))

      Contest.change_attendee_tokens_transaction(
        winner,
        winner.tokens + winnings,
        :winner_update_tokens,
        :previous_daily_tokens,
        :new_daily_tokens
      )
    end)
    |> Repo.transaction()
  end

  @doc """
  Joins an attendee to a coin flip room.

  ## Parameters

    - room_id: The ID of the coin flip room to join.
    - attendee: The attendee attempting to join the room.

  ## Returns

    - `{:ok, "You have joined the room."}` if the attendee successfully joins the room.
    - `{:error, "You cannot join your own room."}` if the attendee is trying to join their own room.
    - `{:error, "The room is already full."}` if the room already has two players.

  ## Examples

      iex> join_coin_flip_room("room_id", %Attendee{id: "attendee_id"})
      {:ok, "You have joined the room."}

      iex> join_coin_flip_room("room_id", %Attendee{id: "player1_id"})
      {:error, "You cannot join your own room."}

      iex> join_coin_flip_room("room_id", %Attendee{id: "other_attendee_id"})
      {:error, "The room is already full."}
  """
  def join_coin_flip_room(room_id, attendee) do
    cond do
      not coin_flip_active?() ->
        {:error, "The coin flip game is not active."}

      has_active_coin_flip_game?(attendee.id) ->
        {:error, "You already have an active game."}

      true ->
        case get_coin_flip_room!(room_id) do
          %CoinFlipRoom{player1_id: player1_id} when player1_id == attendee.id ->
            {:error, "You cannot join your own room."}

          %CoinFlipRoom{player2_id: nil} = room ->
            case join_coin_flip_room_transaction(room, attendee.id) do
              {:ok, result} ->
                coin_flip_room =
                  result.coin_flip_room
                  |> Map.put(:finished, false)
                  |> Map.put(:player2, attendee)
                  |> Repo.preload(player2: :user)

                # If the join is successful, it means the game has started, so,
                # trigger the badge event (for both attendees)
                Contest.enqueue_badge_trigger_execution_job(attendee, :play_coin_flip_event)
                Contest.enqueue_badge_trigger_execution_job(room.player1, :play_coin_flip_event)

                broadcast_coin_flip_rooms_update("update", coin_flip_room)
                {:ok, coin_flip_room}

              {:error, _, _changeset, _} ->
                {:error, "Failed to join the room."}
            end

          _ ->
            {:error, "The room is already full."}
        end
    end
  end

  defp flip_coin do
    if strong_randomizer() > 0.5 do
      "heads"
    else
      "tails"
    end
  end

  @doc """
  Subscribes the caller to the coin flip's configuration updates.

  ## Examples

      iex> subscribe_to_coin_flip_config_update()
      :ok
  """
  def subscribe_to_coin_flip_config_update(config) do
    Phoenix.PubSub.subscribe(@pubsub, coin_flip_config_topic(config))
  end

  defp coin_flip_config_topic(config), do: "coin_flip_config:#{config}"

  defp broadcast_coin_flip_config_update(config, value) do
    Phoenix.PubSub.broadcast(@pubsub, coin_flip_config_topic(config), {config, value})
  end

  @doc """
  Subscribes the caller to the coin flip rooms updates.

  ## Examples

      iex> subscribe_to_coin_flip_rooms_update()
      :ok
  """
  def subscribe_to_coin_flip_rooms_update do
    Phoenix.PubSub.subscribe(@pubsub, coin_flip_rooms_topic())
  end

  defp coin_flip_rooms_topic, do: "coin_flip_rooms"

  defp broadcast_coin_flip_rooms_update(action, value) do
    Phoenix.PubSub.broadcast(@pubsub, coin_flip_rooms_topic(), {action, value})
  end

  @doc """
  Returns the list of slots_reel_icons.

  ## Examples

      iex> list_slots_reel_icons()
      [%SlotsReelIcon{}, ...]

  """
  def list_slots_reel_icons do
    Repo.all(SlotsReelIcon)
  end

  @doc """
  Gets a single slots_reel_icon.

  Raises `Ecto.NoResultsError` if the Slots reel does not exist.

  ## Examples

      iex> get_slots_reel_icon!(123)
      %SlotsReelIcon{}

      iex> get_slots_reel_icon!(456)
      ** (Ecto.NoResultsError)

  """
  def get_slots_reel_icon!(id), do: Repo.get!(SlotsReelIcon, id)

  @doc """
  Creates a slots_reel_icon.

  ## Examples

      iex> create_slots_reel_icon(%{field: value})
      {:ok, %SlotsReelIcon{}}

      iex> create_slots_reel_icon(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_slots_reel_icon(attrs \\ %{}) do
    %SlotsReelIcon{}
    |> SlotsReelIcon.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a slots_reel_icon.

  ## Examples

      iex> update_slots_reel_icon(slots_reel_icon, %{field: new_value})
      {:ok, %SlotsReelIcon{}}

      iex> update_slots_reel_icon(slots_reel_icon, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_slots_reel_icon(%SlotsReelIcon{} = slots_reel_icon, attrs) do
    slots_reel_icon
    |> SlotsReelIcon.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a slots_reel_icon.

  ## Examples

      iex> delete_slots_reel_icon(slots_reel_icon)
      {:ok, %SlotsReelIcon{}}

      iex> delete_slots_reel_icon(slots_reel_icon)
      {:error, %Ecto.Changeset{}}

  """
  def delete_slots_reel_icon(%SlotsReelIcon{} = slots_reel_icon) do
    Repo.delete(slots_reel_icon)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking slots_reel_icon changes.

  ## Examples

      iex> change_slots_reel_icon(slots_reel_icon)
      %Ecto.Changeset{data: %SlotsReelIcon{}}

  """
  def change_slots_reel_icon(%SlotsReelIcon{} = slots_reel_icon, attrs \\ %{}) do
    SlotsReelIcon.changeset(slots_reel_icon, attrs)
  end

  @doc """
  Updates a slots reel image.

  ## Examples

      iex> update_slots_reel_icon_image(slots_reel_icon, %{image: image})
      {:ok, %SlotsReelIcon{}}

      iex> update_slots_reel_icon_image(slots_reel_icon, %{image: bad_image})
      {:error, %Ecto.Changeset{}}

  """
  def update_slots_reel_icon_image(%SlotsReelIcon{} = slots_reel_icon, attrs) do
    slots_reel_icon
    |> SlotsReelIcon.image_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns the list of slots_paytables.

  ## Examples

      iex> list_slots_paytables()
      [%SlotsPaytable{}, ...]

  """
  def list_slots_paytables do
    Repo.all(SlotsPaytable)
  end

  @doc """
  Gets a single slots_paytable.

  Raises `Ecto.NoResultsError` if the Slots paytable does not exist.

  ## Examples

      iex> get_slots_paytable!(123)
      %SlotsPaytable{}

      iex> get_slots_paytable!(456)
      ** (Ecto.NoResultsError)

  """
  def get_slots_paytable!(id), do: Repo.get!(SlotsPaytable, id)

  @doc """
  Creates a slots_paytable.

  ## Examples

      iex> create_slots_paytable(%{field: value})
      {:ok, %SlotsPaytable{}}

      iex> create_slots_paytable(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_slots_paytable(attrs \\ %{}) do
    %SlotsPaytable{}
    |> SlotsPaytable.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a slots_paytable.

  ## Examples

      iex> update_slots_paytable(slots_paytable, %{field: new_value})
      {:ok, %SlotsPaytable{}}

      iex> update_slots_paytable(slots_paytable, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_slots_paytable(%SlotsPaytable{} = slots_paytable, attrs) do
    slots_paytable
    |> SlotsPaytable.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a slots_paytable.

  ## Examples

      iex> delete_slots_paytable(slots_paytable)
      {:ok, %SlotsPaytable{}}

      iex> delete_slots_paytable(slots_paytable)
      {:error, %Ecto.Changeset{}}

  """
  def delete_slots_paytable(%SlotsPaytable{} = slots_paytable) do
    Repo.delete(slots_paytable)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking slots_paytable changes.

  ## Examples

      iex> change_slots_paytable(slots_paytable)
      %Ecto.Changeset{data: %SlotsPaytable{}}

  """
  def change_slots_paytable(%SlotsPaytable{} = slots_paytable, attrs \\ %{}) do
    SlotsPaytable.changeset(slots_paytable, attrs)
  end

  @doc """
  Changes the slots active status.

  ## Examples

      iex> change_slots_active(true)
      :ok
  """
  def change_slots_active(active) do
    Constants.set("slots_active_status", active)
    broadcast_slots_config_update("is_active", active)
  end

  @doc """
  Gets the slots active status.

  ## Examples

      iex> slots_active?()
      true
  """
  def slots_active? do
    case Constants.get("slots_active_status") do
      {:ok, active} ->
        active

      {:error, _} ->
        # If the active status is not set, set it to true by default
        change_slots_active(true)
        true
    end
  end

  @doc """
  Subscribes the caller to the slots' configuration updates.

  ## Examples

      iex> subscribe_to_slots_config_update()
      :ok
  """
  def subscribe_to_slots_config_update(config) do
    Phoenix.PubSub.subscribe(@pubsub, slots_config_topic(config))
  end

  defp slots_config_topic(config), do: "slots:#{config}"

  defp broadcast_slots_config_update(config, value) do
    Phoenix.PubSub.broadcast(@pubsub, slots_config_topic(config), {config, value})
  end

  @doc """
  Returns the list of slots_paylines.

  ## Examples

      iex> list_slots_paylines()
      [%SlotsPayline{}, ...]

  """
  def list_slots_paylines do
    Repo.all(SlotsPayline)
  end

  @doc """
  Gets a single slots_payline.

  Raises `Ecto.NoResultsError` if the Slots payline does not exist.

  ## Examples

      iex> get_slots_payline!(123)
      %SlotsPayline{}

      iex> get_slots_payline!(456)
      ** (Ecto.NoResultsError)

  """
  def get_slots_payline!(id), do: Repo.get!(SlotsPayline, id)

  @doc """
  Creates a slots_payline.

  ## Examples

      iex> create_slots_payline(%{field: value})
      {:ok, %SlotsPayline{}}

      iex> create_slots_payline(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_slots_payline(attrs \\ %{}) do
    %SlotsPayline{}
    |> SlotsPayline.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a slots_payline.

  ## Examples

      iex> update_slots_payline(slots_payline, %{field: new_value})
      {:ok, %SlotsPayline{}}

      iex> update_slots_payline(slots_payline, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_slots_payline(%SlotsPayline{} = slots_payline, attrs) do
    slots_payline
    |> SlotsPayline.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a slots_payline.

  ## Examples

      iex> delete_slots_payline(slots_payline)
      {:ok, %SlotsPayline{}}

      iex> delete_slots_payline(slots_payline)
      {:error, %Ecto.Changeset{}}

  """
  def delete_slots_payline(%SlotsPayline{} = slots_payline) do
    Repo.delete(slots_payline)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking slots_payline changes.

  ## Examples

      iex> change_slots_payline(slots_payline)
      %Ecto.Changeset{data: %SlotsPayline{}}

  """
  def change_slots_payline(%SlotsPayline{} = slots_payline, attrs \\ %{}) do
    SlotsPayline.changeset(slots_payline, attrs)
  end

  @doc """
  Spins the slots for an attendee.

  ## Examples

      iex> spin_slots(%Attendee{}, 20)
      {:ok, %Attendee{}, 2, 100, 40}
  """
  def spin_slots(attendee, bet) do
    attendee = Accounts.get_attendee!(attendee.id)

    if slots_active?() do
      case spin_slots_transaction(attendee, bet) do
        {:ok, result} ->
          # If the slots spin successfully, trigger the badge event
          Contest.enqueue_badge_trigger_execution_job(attendee, :play_slots_event)

          {:ok, result.target, result.paytable_entry.multiplier,
           result.attendee_state_tokens.tokens, result.winnings}

        {:error, _} ->
          {:error, "An error occurred while spinning the slots."}
      end
    else
      {:error, "The slots are not active."}
    end
  end

  defp spin_slots_transaction(attendee, bet) do
    Multi.new()
    # Remove the bet from attendee's balance
    |> Multi.merge(fn _changes ->
      Contest.change_attendee_tokens_transaction(attendee, attendee.tokens - bet, :attendee)
    end)
    |> Multi.put(:paylines, list_slots_paylines())
    |> Multi.put(:slots_reel_icons_count, count_visible_slots_reel_icons(list_slots_reel_icons()))
    # Get random multiplier from paytable based on probabilities
    |> Multi.run(:paytable_entry, fn _repo, %{paylines: paylines} ->
      {:ok, generate_slots_multiplier(paylines)}
    end)
    # Get random payline for the selected multiplier
    |> Multi.run(:target, fn _repo,
                             %{
                               paylines: paylines,
                               slots_reel_icons_count: slots_reel_icons_count,
                               paytable_entry: multiplier
                             } ->
      {:ok, generate_slots_target(paylines, slots_reel_icons_count, multiplier)}
    end)
    |> Multi.run(:winnings, fn _repo, %{paytable_entry: paytable_entry} ->
      winnings = bet * paytable_entry.multiplier
      {:ok, winnings}
    end)
    # Award tokens based on multiplier
    |> Multi.merge(fn %{attendee: attendee, winnings: winnings} ->
      Contest.change_attendee_tokens_transaction(
        attendee,
        attendee.tokens + winnings,
        :attendee_state_tokens,
        :previous_daily_tokens,
        :new_daily_tokens
      )
    end)
    |> Repo.transaction()
  end

  defp generate_slots_multiplier(paylines) do
    random = strong_randomizer() |> Float.round(12)
    multipliers = list_slots_paytables()

    cumulative_probabilities =
      multipliers
      |> Enum.sort_by(& &1.probability)
      |> Enum.map_reduce(0, fn multiplier, acc ->
        {Float.round(acc + multiplier.probability, 12), acc + multiplier.probability}
      end)

    total_prob = elem(cumulative_probabilities, 1)

    if random > total_prob do
      # Return losing multiplier for remaining probability
      %SlotsPaytable{multiplier: 0, probability: 1 - total_prob}
    else
      prob =
        cumulative_probabilities
        |> elem(0)
        |> Enum.filter(fn x -> x >= random end)
        |> Enum.at(0)

      paytable_entry =
        Enum.sort_by(multipliers, & &1.probability)
        |> Enum.at(cumulative_probabilities |> elem(0) |> Enum.find_index(fn x -> x == prob end))

      filtered_paylines = paylines |> Enum.filter(&(&1.paytable_id == paytable_entry.id))

      if Enum.empty?(filtered_paylines) do
        # Generate random multiplier if no payline exists
        %SlotsPaytable{multiplier: 0, probability: 1 - total_prob}
      else
        paytable_entry
      end
    end
  end

  defp generate_slots_target(paylines, slots_reel_icons_count, multiplier) do
    if multiplier.multiplier == 0 do
      # For losing case, generate target that doesn't match any payline
      all_paylines = list_slots_paylines()
      generate_non_matching_target(all_paylines, slots_reel_icons_count)
    else
      paylines = paylines |> Enum.filter(&(&1.paytable_id == multiplier.id))
      payline = Enum.random(paylines)
      # if the position is nil than it should be random
      position_0 =
        if payline.position_0 == nil,
          do: Enum.random(0..(slots_reel_icons_count[0] - 1)),
          else: payline.position_0

      position_1 =
        if payline.position_1 == nil,
          do: Enum.random(0..(slots_reel_icons_count[1] - 1)),
          else: payline.position_1

      position_2 =
        if payline.position_2 == nil,
          do: Enum.random(0..(slots_reel_icons_count[2] - 1)),
          else: payline.position_2

      [position_0, position_1, position_2]
    end
  end

  defp generate_non_matching_target(paylines, slots_reel_icons_count) do
    target = [
      Enum.random(0..(slots_reel_icons_count[0] - 1)),
      Enum.random(0..(slots_reel_icons_count[1] - 1)),
      Enum.random(0..(slots_reel_icons_count[2] - 1))
    ]

    if Enum.any?(paylines, &match_payline?(&1, target)) do
      generate_non_matching_target(paylines, slots_reel_icons_count)
    else
      target
    end
  end

  defp match_payline?(payline, [t0, t1, t2]) do
    [
      is_nil(payline.position_0) || payline.position_0 == t0,
      is_nil(payline.position_1) || payline.position_1 == t1,
      is_nil(payline.position_2) || payline.position_2 == t2
    ]
    |> Enum.all?(& &1)
  end

  @doc """
  Counts the number of visible slots reel icons in each reel.

  ## Examples

      iex> count_visible_slots_reel_icons(slots_icons)
      %{0 => 3, 1 => 3, 2 => 3}
  """
  def count_visible_slots_reel_icons(slots_icons) do
    slots_icons
    |> Enum.reduce(%{}, fn icon, acc ->
      visible_in_reel_0 = icon.reel_0_index != -1
      visible_in_reel_1 = icon.reel_1_index != -1
      visible_in_reel_2 = icon.reel_2_index != -1

      Map.merge(acc, %{
        0 => if(visible_in_reel_0, do: Map.get(acc, 0, 0) + 1, else: Map.get(acc, 0, 0)),
        1 => if(visible_in_reel_1, do: Map.get(acc, 1, 0) + 1, else: Map.get(acc, 1, 0)),
        2 => if(visible_in_reel_2, do: Map.get(acc, 2, 0) + 1, else: Map.get(acc, 2, 0))
      })
    end)
  end

  def save_reel_order(reel_order, visibility) do
    Ecto.Multi.new()
    |> update_reel_order(reel_order["reel-0"], visibility[0], :reel_0_index)
    |> update_reel_order(reel_order["reel-1"], visibility[1], :reel_1_index)
    |> update_reel_order(reel_order["reel-2"], visibility[2], :reel_2_index)
    |> Pearl.Repo.transaction()
    |> handle_transaction_result()
  end

  defp update_reel_order(multi, reel_order, visibility, reel_index_field) do
    visible_reel_order = Enum.filter(reel_order, fn {id, _index} -> visibility[id] end)
    hidden_reel_order = Enum.filter(reel_order, fn {id, _index} -> not visibility[id] end)

    recalculated_reel_order =
      visible_reel_order
      |> Enum.sort_by(fn {_id, index} -> index end)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {{id, _}, index}, acc -> Map.put(acc, id, index) end)

    final_reel_order =
      Enum.reduce(hidden_reel_order, recalculated_reel_order, fn {id, _}, acc ->
        Map.put(acc, id, -1)
      end)

    Enum.reduce(final_reel_order, multi, fn {id, index}, multi ->
      case get_slots_reel_icon!(id) do
        nil ->
          multi

        reel ->
          Ecto.Multi.update(
            multi,
            {:update_reel, reel_index_field, id},
            change_slots_reel_icon(reel, %{reel_index_field => index})
          )
      end
    end)
  end

  defp handle_transaction_result(transaction_result) do
    case transaction_result do
      {:ok, results} ->
        {:ok, results}

      {:error, _failed_operation, error, _changes} ->
        {:error, "Failed to update reels: #{inspect(error)}"}
    end
  end

  def update_slots_reel_icons(entries, socket) do
    existing_reels = list_slots_reel_icons()

    Ecto.Multi.new()
    |> delete_existing_reels(existing_reels)
    |> create_new_reels(entries, socket)
    |> Repo.transaction()
    |> handle_transaction_result()
  end

  defp delete_existing_reels(multi, reels) do
    Enum.reduce(reels, multi, fn reel, multi ->
      Ecto.Multi.delete(multi, {:delete_reel, reel.id}, reel)
    end)
  end

  defp create_new_reels(multi, entries, socket) do
    Ecto.Multi.run(multi, :create_reels, fn _repo, _changes ->
      results =
        entries
        |> Enum.with_index()
        |> Enum.map(fn {entry, index} ->
          create_reel_with_image(socket, entry, index)
        end)
        |> Enum.map(fn
          {:ok, result} -> result
          error -> error
        end)

      if Enum.all?(results, &is_struct(&1, SlotsReelIcon)) do
        {:ok, results}
      else
        {:error, "Failed to create some reels"}
      end
    end)
  end

  defp create_reel_with_image(socket, entry, index) do
    Phoenix.LiveView.consume_uploaded_entry(socket, entry, fn %{path: path} ->
      create_slots_reel_icon(%{
        "reel_0_index" => index,
        "reel_1_index" => index,
        "reel_2_index" => index
      })
      |> case do
        {:ok, reel} ->
          update_slots_reel_icon_image(reel, %{
            "image" => %Plug.Upload{
              content_type: entry.client_type,
              filename: entry.client_name,
              path: path
            }
          })

        error ->
          error
      end
    end)
  end

  @doc """
  Gets the horse race multiplier.

  ## Examples

      iex> get_horse_race_multiplier()
      2.0
  """
  def get_horse_race_multiplier do
    case Constants.get("horse_race_multiplier") do
      {:ok, multiplier} ->
        multiplier

      {:error, _} ->
        change_horse_race_multiplier(2.0)
        2.0
    end
  end

  @doc """
  Changes the scratch game price.

  ## Examples

      iex> change_scratch_card_price(20)
      :ok
  """
  def change_scratch_card_price(price) do
    Constants.set("scratch_card_price", price)
    broadcast_scratch_card_config_update("price", price)
  end

  @doc """
  Gets the scratch card price.

  ## Examples

      iex> get_scratch_card_price()
      20
  """
  def get_scratch_card_price do
    case Constants.get("scratch_card_price") do
      {:ok, price} ->
        price

      {:error, _} ->
        # If the price is not set, set it to 0 by default
        change_scratch_card_price(0)
        0
    end
  end

  @doc """
  Changes the horse race multiplier.

  ## Examples

      iex> change_horse_race_multiplier(3.5)
      :ok
  """
  def change_horse_race_multiplier(multiplier) when is_number(multiplier) do
    Constants.set("horse_race_multiplier", multiplier)
    broadcast_horse_race_config_update("multiplier", multiplier)
  end

  @doc """
  Gets the horse race duration in minutes.

  ## Examples

      iex> get_horse_race_duration()
      2
  """
  def get_horse_race_duration do
    case Constants.get("horse_race_duration") do
      {:ok, duration} ->
        duration

      {:error, _} ->
        change_horse_race_duration(2)
        2
    end
  end

  @doc """
  Changes the scratch card active status.

  ## Examples

      iex> change_scratch_card_active(true)
      :ok
  """
  def change_scratch_card_active(active) do
    Constants.set("scratch_card_active_status", active)
    broadcast_scratch_card_config_update("is_active", active)
  end

  @doc """
  Gets the scratch card active status.

  ## Examples

      iex> scratch_card_active?()
      true
  """
  def scratch_card_active? do
    case Constants.get("scratch_card_active_status") do
      {:ok, active} ->
        active

      {:error, _} ->
        # If the active status is not set, set it to false by default
        change_scratch_card_active(true)
        true
    end
  end

  @doc """
  Changes the horse race duration in minutes.

  ## Examples

      iex> change_horse_race_duration(5)
      :ok
  """
  def change_horse_race_duration(minutes) when is_integer(minutes) do
    Constants.set("horse_race_duration", minutes)
    broadcast_horse_race_config_update("duration", minutes)
  end

  @doc """
  Gets the number of horses in a race.

  ## Examples

      iex> get_horse_race_number_of_horses()
      5
  """
  def get_horse_race_number_of_horses do
    case Constants.get("horse_race_number_of_horses") do
      {:ok, count} ->
        count

      {:error, _} ->
        change_horse_race_number_of_horses(5)
        5
    end
  end

  @doc """
  Subscribes the caller to the scratch card's configuration updates.

  ## Examples

      iex> subscribe_to_scratch_card_config_update()
      :ok
  """
  def subscribe_to_scratch_card_config_update(config) do
    Phoenix.PubSub.subscribe(@pubsub, scratch_card_config_topic(config))
  end

  defp scratch_card_config_topic(config), do: "scratch_card:#{config}"

  defp broadcast_scratch_card_config_update(config, value) do
    Phoenix.PubSub.broadcast(@pubsub, scratch_card_config_topic(config), {config, value})
  end

  @doc """
  Subscribes the caller to the scratch card's wins.

  ## Examples

      iex> subscribe_to_scratch_card_wins()
      :ok
  """
  def subscribe_to_scratch_card_wins do
    Phoenix.PubSub.subscribe(@pubsub, "scratch_card_win")
  end

  defp broadcast_scratch_card_win(value) do
    value = value |> Repo.preload(attendee: [:user], drop: [:prize, :badge])

    if not is_nil(value) and not is_nil(value.drop) and
         (not is_nil(value.drop.badge) or not is_nil(value.drop.prize)) do
      Phoenix.PubSub.broadcast(@pubsub, "scratch_card_win", {"win", value})
    else
      :ok
    end
  end

  @doc """
  Changes the number of horses in a race (between 3 and 8).

  ## Examples

      iex> change_horse_race_number_of_horses(7)
      :ok

      iex> change_horse_race_number_of_horses(2)
      ** (FunctionClauseError)
  """
  def change_horse_race_number_of_horses(count)
      when is_integer(count) and count >= 3 and count <= 8 do
    Constants.set("horse_race_number_of_horses", count)
    broadcast_horse_race_config_update("number_of_horses", count)
  end

  @doc """
  Gets the horse race house fee percentage.

  ## Examples

      iex> get_horse_race_house_fee()
      5.0
  """
  def get_horse_race_house_fee do
    case Constants.get("horse_race_house_fee") do
      {:ok, fee} ->
        fee

      {:error, _} ->
        change_horse_race_house_fee(5.0)
        5.0
    end
  end

  @doc """
  Changes the horse race house fee percentage.

  ## Examples

      iex> change_horse_race_house_fee(10.0)
      :ok
  """
  def change_horse_race_house_fee(fee) when is_number(fee) do
    Constants.set("horse_race_house_fee", fee)
    broadcast_horse_race_config_update("house_fee", fee)
  end

  @doc """
  Gets the horse race active status.

  ## Examples

      iex> horse_race_active?()
      true
  """
  def horse_race_active? do
    case Constants.get("horse_race_active") do
      {:ok, active} ->
        active

      {:error, _} ->
        change_horse_race_active(false)
        false
    end
  end

  @doc """
  Changes the horse race active status.

  ## Examples

      iex> change_horse_race_active(true)
      :ok
  """
  def change_horse_race_active(active?) when is_boolean(active?) do
    Constants.set("horse_race_active", active?)
    broadcast_horse_race_config_update("is_active", active?)
  end

  @doc """
  Subscribe to horse race config updates.

  ## Examples

      iex> subscribe_to_horse_race_config_update("is_active")
      :ok
  """
  def subscribe_to_horse_race_config_update(config) do
    Phoenix.PubSub.subscribe(@pubsub, horse_race_config_topic(config))
  end

  defp horse_race_config_topic(config), do: "horse_race_config:#{config}"

  defp broadcast_horse_race_config_update(config, value) do
    Phoenix.PubSub.broadcast(
      @pubsub,
      horse_race_config_topic(config),
      {:horse_race_config_updated, config, value}
    )
  end

  @doc """
  Subscribes the current process to horse race result events.
  """
  def subscribe_to_horse_race_results do
    Phoenix.PubSub.subscribe(@pubsub, "horse_race:results")
  end

  @doc """
  Broadcasts that a horse race has finished with a winning horse.
  """
  def broadcast_horse_race_result(winning_horse) do
    Phoenix.PubSub.broadcast(@pubsub, "horse_race:results", {:race_finished, winning_horse})
  end

  @doc """
  Subscribes the current process to horse race start events (carries the shared race_id).
  """
  def subscribe_to_horse_race_start do
    Phoenix.PubSub.subscribe(@pubsub, "horse_race:start")
  end

  @doc """
  Broadcasts that a new horse race has started, including the canonical race_id that
  attendees must use when placing bets.
  """
  def broadcast_horse_race_start(race_id) do
    set_current_horse_race_id(race_id)
    Phoenix.PubSub.broadcast(@pubsub, "horse_race:start", {:horse_race_started, race_id})
  end

  @doc """
  Stores the currently-active race ID in the application environment so that
  attendees who mount after the race starts can still read it.
  """
  def set_current_horse_race_id(race_id) do
    Application.put_env(:pearl, :current_horse_race_id, race_id)
  end

  @doc """
  Stores whether the horse race is currently running.
  """
  def set_horse_race_running(is_running) do
    Application.put_env(:pearl, :horse_race_running, is_running)
    Phoenix.PubSub.broadcast(@pubsub, "horse_race:running", {:horse_race_running, is_running})
  end

  @doc """
  Returns whether the horse race is currently running.
  """
  def horse_race_running? do
    Application.get_env(:pearl, :horse_race_running, false)
  end

  @doc """
  Subscribes to horse race running state updates.
  """
  def subscribe_to_horse_race_running do
    Phoenix.PubSub.subscribe(@pubsub, "horse_race:running")
  end

  @doc """
  Returns the currently-active race ID, or nil if no race is running.
  """
  def get_current_horse_race_id do
    Application.get_env(:pearl, :current_horse_race_id)
  end

  @doc """
  Cancels all pending bets that do not belong to `current_race_id`.
  Called when a new race starts to clean up stale state from previous races.
  """
  def cancel_stale_pending_bets(current_race_id) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    HorseRaceBet
    |> where([b], b.status == "pending" and b.race_id != ^current_race_id)
    |> Repo.update_all(set: [status: "cancelled", processed_at: now])
  end

  @doc """
  Generates a unique race ID based on timestamp and random bytes.
  """
  def generate_race_id do
    timestamp = System.system_time(:millisecond)
    random = :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)
    "race-#{timestamp}-#{random}"
  end

  @doc """
  Returns the current token balance of an attendee as a float.
  """
  def get_attendee_tokens(attendee_id) do
    Repo.get!(Attendee, attendee_id).tokens * 1.0
  end

  @doc """
  Returns the most recently processed (won/lost) bets for an attendee,
  ordered by processed_at descending.
  """
  def get_attendee_recent_processed_bets(attendee_id) do
    HorseRaceBet
    |> where([b], b.attendee_id == ^attendee_id and b.status in ["won", "lost"])
    |> order_by([b], desc: b.processed_at)
    |> limit(10)
    |> Repo.all()
  end

  # Horse Race Betting Functions

  @doc """
  Creates bets for an attendee on a horse race.

  ## Parameters
    - attendee_id: The ID of the attendee placing bets
    - race_id: Unique identifier for the race session
    - horse_bets: Map of %{horse_number => bet_amount}

  ## Returns
    - {:ok, bets} on success
    - {:error, reason} on failure

  ## Examples

      iex> place_horse_race_bets(1, "race-123", %{1 => 10.5, 3 => 5.0})
      {:ok, [%HorseRaceBet{}, ...]}

      iex> place_horse_race_bets(1, "race-123", %{1 => 1000.0})
      {:error, :insufficient_balance}
  """
  def place_horse_race_bets(attendee_id, race_id, horse_bets) when is_map(horse_bets) do
    attendee = Repo.get!(Attendee, attendee_id)
    total_bet = horse_bets |> Map.values() |> Enum.sum() |> to_string() |> Decimal.new()
    attendee_balance = Decimal.new(attendee.tokens)

    if Decimal.compare(total_bet, attendee_balance) == :gt do
      {:error, :insufficient_balance}
    else
      Multi.new()
      |> Multi.run(:check_no_existing_bets, fn _repo, _changes ->
        existing =
          HorseRaceBet
          |> where([b], b.attendee_id == ^attendee_id and b.race_id == ^race_id)
          |> Repo.exists?()

        if existing do
          {:error, :bets_already_placed}
        else
          {:ok, true}
        end
      end)
      |> Multi.run(:validate_balance, fn _repo, _changes ->
        # Re-check balance in transaction
        fresh_attendee = Repo.get!(Attendee, attendee_id)
        fresh_balance = Decimal.new(fresh_attendee.tokens)

        if Decimal.compare(total_bet, fresh_balance) == :gt do
          {:error, :insufficient_balance}
        else
          {:ok, fresh_attendee}
        end
      end)
      |> Multi.update(:deduct_tokens, fn %{validate_balance: attendee} ->
        new_balance = Decimal.sub(Decimal.new(attendee.tokens), total_bet)
        new_balance_int = new_balance |> Decimal.round(0, :floor) |> Decimal.to_integer()
        Attendee.update_tokens_changeset(attendee, %{tokens: new_balance_int})
      end)
      |> Multi.insert_all(:insert_bets, HorseRaceBet, fn _changes ->
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        Enum.map(horse_bets, fn {horse_number, amount} ->
          %{
            attendee_id: attendee_id,
            race_id: race_id,
            horse_number: horse_number,
            bet_amount: Decimal.new(to_string(amount)),
            status: "pending",
            inserted_at: now,
            updated_at: now
          }
        end)
      end)
      |> Multi.run(:fetch_bets, fn _repo, _changes ->
        bets =
          HorseRaceBet
          |> where([b], b.attendee_id == ^attendee_id and b.race_id == ^race_id)
          |> Repo.all()

        {:ok, bets}
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{fetch_bets: bets}} ->
          Contest.enqueue_badge_trigger_execution_job(attendee, :play_horse_race_event)
          {:ok, bets}

        {:error, _step, reason, _changes} ->
          {:error, reason}
      end
    end
  end

  @doc """
  Processes payouts for a completed horse race.

  ## Parameters
    - race_id: The unique identifier for the race
    - winning_horse: The number of the winning horse
    - multiplier: The payout multiplier for winning bets

  ## Returns
    - {:ok, %{winners: winners, losers: losers}} on success
    - {:error, reason} on failure

  ## Examples

      iex> process_horse_race_payouts("race-123", 3, 2.5)
      {:ok, %{winners: [...], losers: [...]}}
  """
  def process_horse_race_payouts(race_id, winning_horse, multiplier) do
    pending_bets =
      HorseRaceBet
      |> where([b], b.race_id == ^race_id and b.status == "pending")
      |> preload(:attendee)
      |> Repo.all()

    if Enum.empty?(pending_bets) do
      {:ok, %{winners: [], losers: []}}
    else
      Multi.new()
      |> process_winning_bets(pending_bets, winning_horse, multiplier)
      |> process_losing_bets(pending_bets, winning_horse)
      |> Repo.transaction()
      |> case do
        {:ok, result} ->
          winners = Map.get(result, :winners, [])
          losers = Map.get(result, :losers, [])
          {:ok, %{winners: winners, losers: losers}}

        {:error, _step, reason, _changes} ->
          {:error, reason}
      end
    end
  end

  @doc """
  Processes payouts for ALL pending horse race bets regardless of race_id.
  This is useful when the backoffice starts a race without a specific race_id.

  ## Parameters
    - winning_horse: The number of the winning horse
    - multiplier: The payout multiplier for winning bets

  ## Returns
    - {:ok, %{winners: winners, losers: losers}} on success
    - {:error, reason} on failure

  ## Examples

      iex> process_all_pending_horse_race_payouts(3, 2.5)
      {:ok, %{winners: [...], losers: [...]}}
  """
  def process_all_pending_horse_race_payouts(winning_horse, multiplier) do
    pending_bets =
      HorseRaceBet
      |> where([b], b.status == "pending")
      |> preload(:attendee)
      |> Repo.all()

    if Enum.empty?(pending_bets) do
      {:ok, %{winners: [], losers: []}}
    else
      Multi.new()
      |> process_winning_bets(pending_bets, winning_horse, multiplier)
      |> process_losing_bets(pending_bets, winning_horse)
      |> Repo.transaction()
      |> case do
        {:ok, result} ->
          winners = Map.get(result, :winners, [])
          losers = Map.get(result, :losers, [])
          {:ok, %{winners: winners, losers: losers}}

        {:error, _step, reason, _changes} ->
          {:error, reason}
      end
    end
  end

  defp process_winning_bets(multi, bets, winning_horse, multiplier) do
    winning_bets = Enum.filter(bets, &(&1.horse_number == winning_horse))

    Enum.reduce(winning_bets, multi, fn bet, acc ->
      payout = Decimal.mult(bet.bet_amount, Decimal.new(Float.to_string(multiplier)))
      payout_int = Decimal.to_integer(Decimal.round(payout, 0))

      acc
      |> Multi.update(
        {:update_winning_bet, bet.id},
        HorseRaceBet.changeset(bet, %{
          status: "won",
          payout_amount: payout,
          processed_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })
      )
      |> Multi.run({:credit_winner, bet.id}, fn _repo, _changes ->
        attendee = Repo.get!(Attendee, bet.attendee_id)
        new_balance = attendee.tokens + payout_int

        attendee
        |> Attendee.update_tokens_changeset(%{tokens: new_balance})
        |> Repo.update()
      end)
    end)
    |> Multi.run(:winners, fn _repo, changes ->
      winners =
        winning_bets
        |> Enum.map(fn bet ->
          updated_bet = Map.get(changes, {:update_winning_bet, bet.id})
          Map.put(updated_bet, :attendee, bet.attendee)
        end)

      {:ok, winners}
    end)
  end

  defp process_losing_bets(multi, bets, winning_horse) do
    losing_bets = Enum.filter(bets, &(&1.horse_number != winning_horse))

    multi =
      Enum.reduce(losing_bets, multi, fn bet, acc ->
        acc
        |> Multi.update(
          {:update_losing_bet, bet.id},
          HorseRaceBet.changeset(bet, %{
            status: "lost",
            payout_amount: Decimal.new(0),
            processed_at: DateTime.utc_now() |> DateTime.truncate(:second)
          })
        )
      end)

    Multi.run(multi, :losers, fn _repo, changes ->
      losers =
        losing_bets
        |> Enum.map(fn bet ->
          updated_bet = Map.get(changes, {:update_losing_bet, bet.id})
          Map.put(updated_bet, :attendee, bet.attendee)
        end)

      {:ok, losers}
    end)
  end

  @doc """
  Gets all bets for a specific race.

  ## Examples

      iex> get_race_bets("race-123")
      [%HorseRaceBet{}, ...]
  """
  def get_race_bets(race_id) do
    HorseRaceBet
    |> where([b], b.race_id == ^race_id)
    |> preload(:attendee)
    |> Repo.all()
  end

  @doc """
  Gets all bets for a specific attendee in a specific race.

  ## Examples

      iex> get_attendee_race_bets(1, "race-123")
      [%HorseRaceBet{}, ...]
  """
  def get_attendee_race_bets(attendee_id, race_id) do
    HorseRaceBet
    |> where([b], b.attendee_id == ^attendee_id and b.race_id == ^race_id)
    |> Repo.all()
  end

  @doc """
  Cancels all pending bets for a race (e.g., if race is cancelled).

  ## Examples

      iex> cancel_race_bets("race-123")
      {:ok, %{count: 5}}
  """
  def cancel_race_bets(race_id) do
    pending_bets =
      HorseRaceBet
      |> where([b], b.race_id == ^race_id and b.status == "pending")
      |> preload(:attendee)
      |> Repo.all()

    Multi.new()
    |> Multi.run(:refund_bets, fn _repo, _changes ->
      Enum.each(pending_bets, fn bet ->
        attendee = Repo.get!(Attendee, bet.attendee_id)
        refund_amount = bet.bet_amount |> Decimal.round(0, :floor) |> Decimal.to_integer()
        new_balance = attendee.tokens + refund_amount

        attendee
        |> Attendee.update_tokens_changeset(%{tokens: new_balance})
        |> Repo.update!()

        bet
        |> HorseRaceBet.changeset(%{
          status: "cancelled",
          processed_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })
        |> Repo.update!()
      end)

      {:ok, length(pending_bets)}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{refund_bets: count}} -> {:ok, %{count: count}}
      {:error, _step, reason, _changes} -> {:error, reason}
    end
  end

  @doc """
  Gets all pending horse race bets for an attendee.

  ## Examples

      iex> get_attendee_pending_bets(1)
      [%HorseRaceBet{}, ...]
  """
  def get_attendee_pending_bets(attendee_id) do
    HorseRaceBet
    |> where([b], b.attendee_id == ^attendee_id and b.status == "pending")
    |> order_by([b], desc: b.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets the saved horse race positions as a list.
  """
  def get_horse_race_positions do
    case Constants.get("horse_race_positions") do
      {:ok, positions} -> positions
      {:error, _} -> []
    end
  end

  @doc """
  Saves the horse race positions.
  """
  def set_horse_race_positions(positions) when is_list(positions) do
    Constants.set("horse_race_positions", positions)
  end

  @doc """
  Gets the saved race elapsed time in milliseconds.
  """
  def get_horse_race_elapsed_time do
    case Constants.get("horse_race_elapsed_time") do
      {:ok, elapsed} -> elapsed
      {:error, _} -> 0
    end
  end

  @doc """
  Saves the race elapsed time in milliseconds.
  """
  def set_horse_race_elapsed_time(elapsed) when is_integer(elapsed) do
    Constants.set("horse_race_elapsed_time", elapsed)
  end

  @doc """
  Clears all saved horse race state.
  """
  def clear_horse_race_state do
    Constants.delete("horse_race_running")
    Constants.delete("horse_race_positions")
    Constants.delete("horse_race_elapsed_time")
  end

  @doc """
  Returns the list of scratch_cards.

  ## Examples

      iex> list_scratch_cards()
      [%ScratchCard{}, ...]

  """
  def list_scratch_cards do
    Repo.all(ScratchCard)
  end

  @doc """
  Gets a single scratch_card.

  Raises `Ecto.NoResultsError` if the Scratch card does not exist.

  ## Examples

      iex> get_scratch_card!(123)
      %ScratchCard{}

      iex> get_scratch_card!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scratch_card!(id), do: Repo.get!(ScratchCard, id)

  @doc """
  Creates a scratch_card.

  ## Examples

      iex> create_scratch_card(%{field: value})
      {:ok, %ScratchCard{}}

      iex> create_scratch_card(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scratch_card(attrs) do
    %ScratchCard{}
    |> ScratchCard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a scratch_card.

  ## Examples

      iex> update_scratch_card(scratch_card, %{field: new_value})
      {:ok, %ScratchCard{}}

      iex> update_scratch_card(scratch_card, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scratch_card(%ScratchCard{} = scratch_card, attrs) do
    scratch_card
    |> ScratchCard.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scratch_card.

  ## Examples

      iex> delete_scratch_card(scratch_card)
      {:ok, %ScratchCard{}}

      iex> delete_scratch_card(scratch_card)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scratch_card(%ScratchCard{} = scratch_card) do
    Repo.delete(scratch_card)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scratch_card changes.

  ## Examples

      iex> change_scratch_card(scratch_card)
      %Ecto.Changeset{data: %ScratchCard{}}

  """
  def change_scratch_card(%ScratchCard{} = scratch_card, attrs \\ %{}) do
    ScratchCard.changeset(scratch_card, attrs)
  end

  @doc """
  Returns the list of scratch_card_symbols from a scratch_card.

  ## Examples

      iex> get_symbols_from_scratch_card()
      [%ScratchCardSymbol{}, ...]

  """
  def get_symbols_from_scratch_card(%ScratchCard{} = scratch_card) do
    ScratchCard
    |> where([sc], sc.id == type(^scratch_card.id, :binary_id))
    |> join(:inner, [sc], s in assoc(sc, :symbols))
    |> select([_cs, s], %ScratchCardSymbol{id: s.id, name: s.name, image: s.image})
    |> Repo.all()
  end

  def buy_scratch_card(attendee) do
    attendee = Accounts.get_attendee!(attendee.id)

    if scratch_card_active?() do
      case buy_scratch_card_transaction(attendee) do
        {:ok, result} ->
          {:ok, result}

        {:error, _, _, _} ->
          {:error, "An error occurred while buying a scratch card"}
      end
    else
      {:error, "Scratch cards are not for sale"}
    end
  end

  def buy_scratch_card_transaction(attendee) do
    Multi.new()
    |> Multi.put(:price, get_scratch_card_price())
    |> Multi.merge(fn %{price: price} ->
      Contest.change_attendee_tokens_transaction(attendee, attendee.tokens - price, :attendee)
    end)
    |> Multi.run(:drop_and_symbols, fn _repo, _changes ->
      {:ok, generate_scratch_card_drop_and_symbols(attendee)}
    end)
    |> Multi.insert(:scratch_card, fn %{drop_and_symbols: {drop, symbols}} ->
      %ScratchCard{}
      |> ScratchCard.changeset(%{
        attendee_id: attendee.id,
        drop_id: if(drop.id, do: drop.id, else: nil)
      })
      |> Ecto.Changeset.put_assoc(:symbols, symbols)
    end)
    # Apply the reward action for the drop
    |> Multi.merge(fn %{drop_and_symbols: {drop, _symbols}, attendee: attendee} ->
      drop_reward_action(drop, attendee)
    end)
    |> Multi.run(:notify, fn _repo, params -> broadcast_scratch_card_purchase_changes(params) end)
    |> Multi.run(:scratch_card_preloaded, fn repo, %{scratch_card: scratch_card} ->
      {:ok, repo.preload(scratch_card, drop: [:prize, :badge])}
    end)
    |> Repo.transaction()
  end

  defp broadcast_scratch_card_purchase_changes(params) do
    case broadcast_scratch_card_win(Map.get(params, :scratch_card)) do
      :ok ->
        case broadcast_scratch_card_config_update("drops", list_scratch_card_drops()) do
          :ok -> {:ok, :ok}
          e -> e
        end

      e ->
        e
    end
  end

  def scratch_card_latest_wins(count) do
    ScratchCard
    |> join(:inner, [sc], d in assoc(sc, :drop))
    |> where([sc, d], not is_nil(d.prize_id) or not is_nil(d.badge_id))
    |> order_by([sc], desc: sc.inserted_at)
    |> limit(^count)
    |> Repo.all()
    |> Repo.preload(attendee: [:user], drop: [:prize, :badge])
  end

  defp generate_scratch_card_drop_and_symbols(attendee) do
    random = strong_randomizer() |> Float.round(12)
    drops = list_available_scratch_card_drops()
    all_symbols = list_scratch_card_symbols()

    cumulative_probabilities =
      drops
      |> Enum.sort_by(& &1.probability)
      |> Enum.map_reduce(0, fn drop, acc ->
        {Float.round(acc + drop.probability, 12), acc + drop.probability}
      end)

    total_prob = elem(cumulative_probabilities, 1)

    if random > total_prob do
      # Return losing drop (no prize) with losing symbols
      losing_drop = %ScratchCardDrop{probability: 1 - total_prob}
      symbols = generate_losing_symbols(all_symbols)

      {losing_drop, symbols}
    else
      prob =
        cumulative_probabilities
        |> elem(0)
        |> Enum.filter(fn x -> x >= random end)
        |> Enum.at(0)

      drop =
        Enum.sort_by(drops, & &1.probability)
        |> Enum.at(cumulative_probabilities |> elem(0) |> Enum.find_index(fn x -> x == prob end))

      if valid_drop?(attendee, drop) && drop.scratch_card_symbol do
        symbols = generate_winning_symbols(drop.scratch_card_symbol, all_symbols)
        {drop, symbols}
      else
        # treat as lost
        symbols = generate_losing_symbols(all_symbols)
        {%ScratchCardDrop{probability: drop.probability}, symbols}
      end
    end
  end

  defp valid_drop?(attendee, drop) do
    case get_drop_type(drop) do
      :prize ->
        get_attendee_prize_inventory_quantity(attendee.id, drop.prize_id) < drop.max_per_attendee

      :badge ->
        !Contest.attendee_owns_badge?(attendee.id, drop.badge_id)

      _ ->
        true
    end
  end

  defp generate_winning_symbols(winning_symbol, all_symbols) do
    win_positions = Enum.shuffle(0..5) |> Enum.take(3)

    other_symbols = all_symbols -- [winning_symbol]

    Enum.map(0..5, fn i ->
      if i in win_positions do
        winning_symbol
      else
        Enum.random(other_symbols)
      end
    end)
  end

  defp generate_losing_symbols(all_symbols) do
    symbols = Enum.map(0..5, fn _ -> Enum.random(all_symbols) end)

    if win?(symbols) do
      generate_losing_symbols(all_symbols)
    else
      symbols
    end
  end

  defp win?(symbols) do
    symbols
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.any?(&(&1 >= 3))
  end

  @doc """
  Returns the list of scratch_card_drops.

  ## Examples

      iex> list_scratch_card_drops()
      [%ScratchCardDrop{}, ...]

  """
  def list_scratch_card_drops do
    ScratchCardDrop
    |> order_by([sc], asc: sc.probability)
    |> Repo.all()
    |> Repo.preload([:badge, :prize, :scratch_card_symbol])
  end

  def list_available_scratch_card_drops do
    ScratchCardDrop
    |> join(:left, [sc], p in Prize, on: sc.prize_id == p.id)
    |> where([sc, p], is_nil(sc.prize_id) or p.stock > 0)
    |> preload([:prize, :badge, :scratch_card_symbol])
    |> Repo.all()
  end

  @doc """
  Gets a single scratch_card_drop.

  Raises `Ecto.NoResultsError` if the Scratch card drop does not exist.

  ## Examples

      iex> get_scratch_card_drop!(123)
      %ScratchCardDrop{}

      iex> get_scratch_card_drop!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scratch_card_drop!(id), do: Repo.get!(ScratchCardDrop, id)

  @doc """
  Creates a scratch_card_drop.

  ## Examples

      iex> create_scratch_card_drop(%{field: value})
      {:ok, %ScratchCardDrop{}}

      iex> create_scratch_card_drop(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scratch_card_drop(attrs) do
    %ScratchCardDrop{}
    |> ScratchCardDrop.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a scratch_card_drop.

  ## Examples

      iex> update_scratch_card_drop(scratch_card_drop, %{field: new_value})
      {:ok, %ScratchCardDrop{}}

      iex> update_scratch_card_drop(scratch_card_drop, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scratch_card_drop(%ScratchCardDrop{} = scratch_card_drop, attrs) do
    scratch_card_drop
    |> ScratchCardDrop.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scratch_card_drop.

  ## Examples

      iex> delete_scratch_card_drop(scratch_card_drop)
      {:ok, %ScratchCardDrop{}}

      iex> delete_scratch_card_drop(scratch_card_drop)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scratch_card_drop(%ScratchCardDrop{} = scratch_card_drop) do
    Repo.delete(scratch_card_drop)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scratch_card_drop changes.

  ## Examples

      iex> change_scratch_card_drop(scratch_card_drop)
      %Ecto.Changeset{data: %ScratchCardDrop{}}

  """
  def change_scratch_card_drop(%ScratchCardDrop{} = scratch_card_drop, attrs \\ %{}) do
    ScratchCardDrop.changeset(scratch_card_drop, attrs)
  end

  @doc """
  Returns the list of scratch_card_symbols.

  ## Examples

      iex> list_scratch_card_symbols()
      [%ScratchCardSymbol{}, ...]

  """
  def list_scratch_card_symbols do
    Repo.all(ScratchCardSymbol)
  end

  @doc """
  Gets a single scratch_card_symbol.

  Raises `Ecto.NoResultsError` if the Scratch card symbol does not exist.

  ## Examples

      iex> get_scratch_card_symbol!(123)
      %ScratchCardSymbol{}

      iex> get_scratch_card_symbol!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scratch_card_symbol!(id), do: Repo.get!(ScratchCardSymbol, id)

  @doc """
  Creates a scratch_card_symbol.

  ## Examples

      iex> create_scratch_card_symbol(%{field: value})
      {:ok, %ScratchCardSymbol{}}

      iex> create_scratch_card_symbol(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scratch_card_symbol(attrs) do
    %ScratchCardSymbol{}
    |> ScratchCardSymbol.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a scratch_card_symbol.

  ## Examples

      iex> update_scratch_card_symbol(scratch_card_symbol, %{field: new_value})
      {:ok, %ScratchCardSymbol{}}

      iex> update_scratch_card_symbol(scratch_card_symbol, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scratch_card_symbol(%ScratchCardSymbol{} = scratch_card_symbol, attrs) do
    scratch_card_symbol
    |> ScratchCardSymbol.changeset(attrs)
    |> Repo.update()
  end

  def update_scratch_card_symbol_image(%ScratchCardSymbol{} = scratch_card_symbol, attrs) do
    scratch_card_symbol
    |> ScratchCardSymbol.image_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scratch_card_symbol.

  ## Examples

      iex> delete_scratch_card_symbol(scratch_card_symbol)
      {:ok, %ScratchCardSymbol{}}

      iex> delete_scratch_card_symbol(scratch_card_symbol)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scratch_card_symbol(%ScratchCardSymbol{} = scratch_card_symbol) do
    Repo.delete(scratch_card_symbol)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scratch_card_symbol changes.

  ## Examples

      iex> change_scratch_card_symbol(scratch_card_symbol)
      %Ecto.Changeset{data: %ScratchCardSymbol{}}

  """
  def change_scratch_card_symbol(%ScratchCardSymbol{} = scratch_card_symbol, attrs \\ %{}) do
    ScratchCardSymbol.changeset(scratch_card_symbol, attrs)
  end
end
