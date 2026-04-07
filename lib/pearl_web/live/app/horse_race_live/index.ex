defmodule PearlWeb.App.HorseRaceLive.Index do
  use PearlWeb, :app_view

  alias Pearl.Minigames

  import PearlWeb.App.HorseRaceLive.Components.ResultModal

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Minigames.subscribe_to_horse_race_config_update("is_active")
      Minigames.subscribe_to_horse_race_config_update("multiplier")
      Minigames.subscribe_to_horse_race_config_update("duration")
      Minigames.subscribe_to_horse_race_config_update("number_of_horses")
      Minigames.subscribe_to_horse_race_config_update("house_fee")
      Minigames.subscribe_to_horse_race_results()
      Minigames.subscribe_to_horse_race_start()
      Minigames.subscribe_to_horse_race_running()
    end

    {:ok,
     socket
     |> assign(:current_page, :horse_race)
     |> assign(:horse_race_active?, Minigames.horse_race_active?())
     |> assign(:horse_race_running?, Minigames.horse_race_running?())
     |> assign(:multiplier, Minigames.get_horse_race_multiplier())
     |> assign(:duration_minutes, Minigames.get_horse_race_duration())
     |> assign(:number_of_horses, Minigames.get_horse_race_number_of_horses())
     |> assign(
       :attendee_tokens,
       Minigames.get_attendee_tokens(socket.assigns.current_user.attendee.id)
     )
     |> assign(:current_race_id, Minigames.get_current_horse_race_id())
     |> assign(:race_result, nil)
     |> assign(
       :active_bets,
       Minigames.get_attendee_pending_bets(socket.assigns.current_user.attendee.id)
     )
     |> assign_bet_totals(%{})}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:horse_race_config_updated, "is_active", is_active}, socket) do
    {:noreply, assign(socket, :horse_race_active?, is_active)}
  end

  def handle_info({:horse_race_config_updated, "multiplier", multiplier}, socket) do
    {:noreply,
     socket
     |> assign(:multiplier, multiplier)
     |> assign_bet_totals(socket.assigns.horse_bets)}
  end

  def handle_info({:horse_race_config_updated, "duration", duration}, socket) do
    {:noreply, assign(socket, :duration_minutes, duration)}
  end

  def handle_info({:horse_race_config_updated, "number_of_horses", number_of_horses}, socket) do
    {:noreply, assign(socket, :number_of_horses, number_of_horses)}
  end

  def handle_info({:horse_race_config_updated, "house_fee", _house_fee}, socket) do
    {:noreply, socket}
  end

  def handle_info({:horse_race_running, is_running}, socket) do
    {:noreply, assign(socket, :horse_race_running?, is_running)}
  end

  def handle_info({:horse_race_started, race_id}, socket) do
    {:noreply,
     socket
     |> assign(:current_race_id, race_id)
     |> assign(:active_bets, [])
     |> assign_bet_totals(%{})}
  end

  def handle_info({:race_finished, winning_horse}, socket) do
    if socket.assigns.active_bets != [] do
      attendee_id = socket.assigns.current_user.attendee.id
      bets = Minigames.get_attendee_recent_processed_bets(attendee_id)
      updated_tokens = Minigames.get_attendee_tokens(attendee_id)

      active_bet_ids = MapSet.new(socket.assigns.active_bets, & &1.id)

      winning_bets =
        Enum.filter(bets, fn b -> MapSet.member?(active_bet_ids, b.id) && b.status == "won" end)

      losing_bets =
        Enum.filter(bets, fn b -> MapSet.member?(active_bet_ids, b.id) && b.status == "lost" end)

      total_losses =
        losing_bets
        |> Enum.map(& &1.bet_amount)
        |> Enum.reduce(Decimal.new(0), &Decimal.add/2)
        |> Decimal.to_float()

      socket =
        if winning_bets != [] do
          total_payout =
            winning_bets
            |> Enum.map(& &1.payout_amount)
            |> Enum.reduce(Decimal.new(0), &Decimal.add/2)
            |> Decimal.to_float()

          assign(socket, :race_result, %{
            winning_horse: winning_horse,
            winnings: format_tokens(total_payout),
            losses: format_tokens(total_losses)
          })
        else
          assign(socket, :race_result, %{
            winning_horse: winning_horse,
            winnings: 0,
            losses: format_tokens(total_losses)
          })
        end

      {:noreply,
       socket
       |> assign(:attendee_tokens, updated_tokens)
       |> assign(:active_bets, [])
       |> assign_bet_totals(socket.assigns.horse_bets)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  def handle_event("clear_result", _params, socket) do
    {:noreply, assign(socket, :race_result, nil)}
  end

  @impl true
  def handle_event("update_horse_bet", %{"horse" => horse_str, "amount" => amount_str}, socket) do
    if socket.assigns.horse_race_running? do
      {:noreply, socket}
    else
      horse_number = String.to_integer(horse_str)
      other_bets = socket.assigns.horse_bets |> Map.delete(horse_number) |> calculate_total_bets()
      available = trunc(socket.assigns.attendee_tokens) - other_bets

      bet_amount =
        case Integer.parse(amount_str) do
          {value, _} when value >= 1 and value <= available -> value
          {value, _} when value > available -> available
          _ -> 0
        end

      horse_bets =
        if bet_amount >= 1 do
          Map.put(socket.assigns.horse_bets, horse_number, bet_amount)
        else
          Map.delete(socket.assigns.horse_bets, horse_number)
        end

      {:noreply, assign_bet_totals(socket, horse_bets)}
    end
  end

  def handle_event("update_horse_bet", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("clear_horse_bet", %{"horse" => horse_str}, socket) do
    if socket.assigns.horse_race_running? do
      {:noreply, socket}
    else
      horse_number = String.to_integer(horse_str)
      horse_bets = Map.delete(socket.assigns.horse_bets, horse_number)

      {:noreply, assign_bet_totals(socket, horse_bets)}
    end
  end

  def handle_event("clear_all_bets", _params, socket) do
    if socket.assigns.horse_race_running? do
      {:noreply, socket}
    else
      {:noreply, assign_bet_totals(socket, %{})}
    end
  end

  def handle_event("confirm_bets", _params, socket) do
    cond do
      socket.assigns.horse_race_running? ->
        {:noreply,
         put_flash(
           socket,
           :error,
           gettext("The race is already running! You can't place bets now.")
         )}

      map_size(socket.assigns.horse_bets) == 0 ->
        {:noreply, put_flash(socket, :error, "Não há apostas para confirmar!")}

      socket.assigns.active_bets != [] ->
        {:noreply, put_flash(socket, :error, "Já tens apostas ativas nesta corrida!")}

      is_nil(socket.assigns.current_race_id) ->
        {:noreply,
         put_flash(socket, :error, "Nenhuma corrida ativa. Aguarda o início da próxima corrida.")}

      true ->
        process_bets(socket)
    end
  end

  defp process_bets(socket) do
    attendee_id = socket.assigns.current_user.attendee.id
    race_id = socket.assigns.current_race_id
    horse_bets = socket.assigns.horse_bets

    case Minigames.place_horse_race_bets(attendee_id, race_id, horse_bets) do
      {:ok, bets} ->
        total_bet = calculate_total_bets(horse_bets)

        attendee_tokens = Minigames.get_attendee_tokens(attendee_id)

        {:noreply,
         socket
         |> assign(:attendee_tokens, attendee_tokens)
         |> assign(:race_result, nil)
         |> assign(:active_bets, bets)
         |> assign_bet_totals(%{})
         |> put_flash(
           :info,
           "Apostas confirmadas! Total: #{format_tokens(total_bet)} tokens. Aguarda o fim da corrida!"
         )}

      {:error, :insufficient_balance} ->
        {:noreply, put_flash(socket, :error, "Saldo insuficiente!")}

      {:error, :bets_already_placed} ->
        {:noreply, put_flash(socket, :error, "Já colocaste apostas nesta corrida!")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Erro ao colocar apostas. Tenta novamente.")}
    end
  end

  defp calculate_total_bets(horse_bets) do
    horse_bets |> Map.values() |> Enum.sum()
  end

  defp assign_bet_totals(socket, horse_bets) do
    total_bets = calculate_total_bets(horse_bets)
    available_tokens = socket.assigns.attendee_tokens - total_bets

    active_bets = socket.assigns.active_bets || []

    total_active_bets =
      active_bets
      |> Enum.map(& &1.bet_amount)
      |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

    multiplier_decimal = parse_multiplier(socket.assigns.multiplier)

    max_return = calculate_max_return(active_bets, multiplier_decimal)

    net_gain =
      if Enum.empty?(active_bets) do
        Decimal.new(0)
      else
        Decimal.sub(max_return, total_active_bets)
      end

    enriched_active_bets = enrich_active_bets(active_bets, multiplier_decimal, total_active_bets)

    assign(socket,
      horse_bets: horse_bets,
      total_bets: total_bets,
      available_tokens: available_tokens,
      active_bets: enriched_active_bets,
      total_active_bets: total_active_bets,
      max_return: max_return,
      net_gain: net_gain,
      multiplier_decimal: multiplier_decimal
    )
  end

  defp calculate_max_return(active_bets, multiplier_decimal) do
    active_bets
    |> Enum.map(& &1.bet_amount)
    |> Enum.map(fn bet -> Decimal.mult(bet, multiplier_decimal) end)
    |> Enum.reduce(nil, fn
      value, nil -> value
      value, acc -> if Decimal.compare(value, acc) == :gt, do: value, else: acc
    end) || Decimal.new(0)
  end

  defp parse_multiplier(multiplier) do
    cond do
      is_integer(multiplier) -> Decimal.new(multiplier)
      is_float(multiplier) -> Decimal.from_float(multiplier)
      match?(%Decimal{}, multiplier) -> multiplier
      true -> Decimal.new(trunc(multiplier || 0))
    end
  end

  defp enrich_active_bets(active_bets, multiplier_decimal, total_active_bets) do
    Enum.map(active_bets, fn bet ->
      bet_max_return = Decimal.mult(bet.bet_amount, multiplier_decimal)
      bet_net_gain = Decimal.sub(bet_max_return, total_active_bets)
      bet_net_cmp = Decimal.compare(bet_net_gain, Decimal.new(0))

      bet
      |> Map.from_struct()
      |> Map.merge(%{
        bet_max_return: bet_max_return,
        bet_net_gain: bet_net_gain,
        bet_net_cmp: bet_net_cmp
      })
    end)
  end

  defp horse_variant_class(horse_number) do
    case rem(horse_number - 1, 4) do
      0 -> "horse-variant-gold"
      1 -> "horse-variant-brown"
      2 -> "horse-variant-grey"
      3 -> "horse-variant-black"
    end
  end

  # Front-end should display integers only (no decimal floating points)
  def format_tokens(value) when is_integer(value), do: value
  def format_tokens(value) when is_float(value), do: trunc(value)
  def format_tokens(%Decimal{} = value), do: value |> Decimal.to_float() |> trunc()
  def format_tokens(value), do: value
end
