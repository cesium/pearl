defmodule PearlWeb.App.HorseRaceLive.Index do
  use PearlWeb, :app_view

  alias Pearl.Minigames

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
    end

    {:ok,
     socket
     |> assign(:current_page, :horse_race)
     |> assign(:horse_race_active?, Minigames.horse_race_active?())
     |> assign(:multiplier, Minigames.get_horse_race_multiplier())
     |> assign(:duration_minutes, Minigames.get_horse_race_duration())
     |> assign(:number_of_horses, Minigames.get_horse_race_number_of_horses())
     |> assign(
       :attendee_tokens,
       Minigames.get_attendee_tokens(socket.assigns.current_user.attendee.id)
     )
     |> assign(:current_race_id, Minigames.get_current_horse_race_id())
     |> assign(:horse_bets, %{})
     |> assign(:active_bets, [])}
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
    {:noreply, assign(socket, :multiplier, multiplier)}
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

  def handle_info({:horse_race_started, race_id}, socket) do
    {:noreply,
     socket
     |> assign(:current_race_id, race_id)
     |> assign(:horse_bets, %{})
     |> assign(:active_bets, [])}
  end

  def handle_info({:race_finished, winning_horse}, socket) do
    if length(socket.assigns.active_bets) > 0 do
      attendee_id = socket.assigns.current_user.attendee.id
      bets = Minigames.get_attendee_recent_processed_bets(attendee_id)
      updated_tokens = Minigames.get_attendee_tokens(attendee_id)

      active_bet_ids = MapSet.new(socket.assigns.active_bets, & &1.id)

      winning_bets =
        Enum.filter(bets, fn b -> MapSet.member?(active_bet_ids, b.id) && b.status == "won" end)

      socket =
        if length(winning_bets) > 0 do
          total_payout =
            winning_bets
            |> Enum.map(& &1.payout_amount)
            |> Enum.reduce(Decimal.new(0), &Decimal.add/2)
            |> Decimal.to_float()

          put_flash(
            socket,
            :info,
            "Parabéns! O cavalo ##{winning_horse} ganhou! Recebeste #{format_tokens(total_payout)} tokens!"
          )
        else
          put_flash(
            socket,
            :error,
            "O cavalo ##{winning_horse} ganhou. Melhor sorte da próxima vez!"
          )
        end

      {:noreply,
       socket
       |> assign(:attendee_tokens, updated_tokens)
       |> assign(:active_bets, [])}
    else
      {:noreply, socket}
    end
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_horse_bet", %{"horse" => horse_str, "amount" => amount_str}, socket) do
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

    {:noreply, assign(socket, :horse_bets, horse_bets)}
  end

  def handle_event("update_horse_bet", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("clear_horse_bet", %{"horse" => horse_str}, socket) do
    horse_number = String.to_integer(horse_str)
    horse_bets = Map.delete(socket.assigns.horse_bets, horse_number)
    {:noreply, assign(socket, :horse_bets, horse_bets)}
  end

  def handle_event("clear_all_bets", _params, socket) do
    {:noreply, assign(socket, :horse_bets, %{})}
  end

  def handle_event("confirm_bets", _params, socket) do
    horse_bets = socket.assigns.horse_bets

    cond do
      map_size(horse_bets) == 0 ->
        {:noreply, put_flash(socket, :error, "Não há apostas para confirmar!")}

      length(socket.assigns.active_bets) > 0 ->
        {:noreply, put_flash(socket, :error, "Já tens apostas ativas nesta corrida!")}

      is_nil(socket.assigns.current_race_id) ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Nenhuma corrida ativa. Aguarda o início da próxima corrida."
         )}

      true ->
        attendee_id = socket.assigns.current_user.attendee.id
        race_id = socket.assigns.current_race_id

        case Minigames.place_horse_race_bets(attendee_id, race_id, horse_bets) do
          {:ok, bets} ->
            total_bet = calculate_total_bets(horse_bets)

            {:noreply,
             socket
             |> assign(:attendee_tokens, Minigames.get_attendee_tokens(attendee_id))
             |> assign(:horse_bets, %{})
             |> assign(:active_bets, bets)
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
  end

  defp calculate_total_bets(horse_bets) do
    horse_bets |> Map.values() |> Enum.sum()
  end

  def format_tokens(value) when is_integer(value), do: Float.round(value * 1.0, 2)
  def format_tokens(value) when is_float(value), do: Float.round(value, 2)
  def format_tokens(%Decimal{} = value), do: value |> Decimal.to_float() |> Float.round(2)
  def format_tokens(value), do: value
end
