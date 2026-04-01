defmodule PearlWeb.Backoffice.MinigamesLive.HorseRace.Game do
  @moduledoc false
  use PearlWeb, :backoffice_view

  alias Pearl.Minigames

  on_mount {PearlWeb.StaffRoles, game: %{"minigames" => ["edit"]}}

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Minigames.subscribe_to_horse_race_config_update("is_active")
      Minigames.subscribe_to_horse_race_config_update("multiplier")
      Minigames.subscribe_to_horse_race_config_update("duration")
      Minigames.subscribe_to_horse_race_config_update("number_of_horses")
      Minigames.subscribe_to_horse_race_config_update("house_fee")
    end

    number_of_horses = Minigames.get_horse_race_number_of_horses()
    duration_minutes = Minigames.get_horse_race_duration()
    total_race_time = duration_minutes * 60

    horse_speeds = create_horse_speeds(number_of_horses)

    # Reuse an existing race_id (so bets placed before mount are preserved),
    # or generate a fresh one if this is the first time the page is opened.
    race_id =
      case Minigames.get_current_horse_race_id() do
        nil ->
          new_id = generate_race_id()
          Minigames.broadcast_horse_race_start(new_id)
          new_id

        id ->
          id
      end

    {:ok,
     socket
     |> assign(
       current_page: :minigames,
       is_active: Minigames.horse_race_active?(),
       multiplier: Minigames.get_horse_race_multiplier(),
       duration_minutes: duration_minutes,
       number_of_horses: number_of_horses,
       house_fee: Minigames.get_horse_race_house_fee(),
       horses: List.duplicate(0, number_of_horses),
       horse_speeds: horse_speeds,
       racing: false,
       winner: nil,
       time_remaining: total_race_time,
       time_elapsed: 0,
       total_race_time: total_race_time,
       race_start_time: nil,
       current_race_id: race_id
     )}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_info({:horse_race_config_updated, "is_active", is_active}, socket) do
    {:noreply, assign(socket, :is_active, is_active)}
  end

  def handle_info({:horse_race_config_updated, "multiplier", multiplier}, socket) do
    {:noreply, assign(socket, :multiplier, multiplier)}
  end

  def handle_info({:horse_race_config_updated, "duration", duration}, socket) do
    total_race_time = duration * 60
    {:noreply, assign(socket, duration_minutes: duration, total_race_time: total_race_time)}
  end

  def handle_info({:horse_race_config_updated, "number_of_horses", number_of_horses}, socket) do
    # If not currently racing, update the number of horses
    if socket.assigns.racing do
      {:noreply, socket}
    else
      horse_speeds = create_horse_speeds(number_of_horses)

      {:noreply,
       assign(socket,
         number_of_horses: number_of_horses,
         horses: List.duplicate(0, number_of_horses),
         horse_speeds: horse_speeds
       )}
    end
  end

  def handle_info({:horse_race_config_updated, "house_fee", house_fee}, socket) do
    {:noreply, assign(socket, :house_fee, house_fee)}
  end

  def handle_event("start_race", params, socket) do
    number_of_horses = socket.assigns.number_of_horses
    horse_speeds = create_horse_speeds(number_of_horses)

    duration =
      case params["duration"] do
        duration when is_integer(duration) -> duration
        duration when is_binary(duration) -> String.to_integer(duration)
        nil -> socket.assigns.total_race_time
        _ -> socket.assigns.total_race_time
      end

    # Reuse the race_id that was shared with attendees at mount time so that
    # bets already placed are linked to this race. Never generate a new id here.
    race_id = socket.assigns.current_race_id

    socket =
      socket
      |> assign(
        racing: true,
        winner: nil,
        horses: List.duplicate(0, number_of_horses),
        horse_speeds: horse_speeds,
        time_remaining: socket.assigns.total_race_time,
        time_elapsed: 0,
        race_start_time: System.monotonic_time(:millisecond),
        current_race_id: race_id
      )
      |> push_event("start_race", %{duration: duration})

    Minigames.set_horse_race_running(true)

    {:noreply, socket}
  end

  def handle_event("clear_winner", _params, socket) do
    {:noreply, assign(socket, winner: nil)}
  end

  def handle_event("stop_race", _params, socket) do
    socket =
      socket
      |> assign(racing: false)
      |> push_event("stop_race", %{})

    Minigames.set_horse_race_running(false)

    {:noreply, socket}
  end

  def handle_event("reset_race", _params, socket) do
    number_of_horses = socket.assigns.number_of_horses

    socket =
      socket
      |> assign(
        horses: List.duplicate(0, number_of_horses),
        winner: nil,
        time_remaining: socket.assigns.total_race_time,
        time_elapsed: 0,
        racing: false
      )
      |> push_event("reset_race", %{})

    Minigames.set_horse_race_running(false)

    {:noreply, socket}
  end

  def handle_event("update_race", params, socket) do
    if socket.assigns.racing do
      {:noreply, process_update_race(socket, params)}
    else
      {:noreply, socket}
    end
  end

  defp process_update_race(socket, params) do
    elapsed = parse_elapsed(params["elapsed"])
    time_remaining = max(0, socket.assigns.total_race_time - elapsed)
    client_horses = parse_client_horses(params["positions"])

    if elapsed >= socket.assigns.total_race_time - 1 do
      finish_race(socket, client_horses, params["js_winner"])
    else
      continue_race(socket, elapsed, time_remaining, client_horses)
    end
  end

  defp finish_race(socket, client_horses, js_winner) do
    horses = client_horses || Enum.map(socket.assigns.horses, &min(&1, 100))
    winner = parse_js_winner(js_winner, horses)

    horses = Enum.map(horses, fn _ -> 100 end)

    socket =
      if winner && socket.assigns.current_race_id do
        process_race_payouts(socket, winner)
      else
        socket
      end

    Minigames.set_horse_race_running(false)

    assign(socket,
      horses: horses,
      racing: false,
      winner: winner,
      time_remaining: 0,
      time_elapsed: socket.assigns.total_race_time
    )
  end

  defp continue_race(socket, elapsed, time_remaining, client_horses) do
    new_horses =
      client_horses || update_horse_positions(socket.assigns.horses, socket.assigns.horse_speeds)

    assign(socket,
      horses: new_horses,
      time_remaining: time_remaining,
      time_elapsed: elapsed,
      racing: true
    )
  end

  defp parse_elapsed(elapsed) when is_integer(elapsed), do: elapsed
  defp parse_elapsed(elapsed) when is_binary(elapsed), do: String.to_integer(elapsed)
  defp parse_elapsed(_), do: 0

  defp parse_client_horses(positions) when is_list(positions) do
    Enum.map(positions, fn
      p when is_binary(p) ->
        case Float.parse(p) do
          {f, _} -> f
          :error -> 0.0
        end

      p when is_number(p) ->
        p * 1.0

      _ ->
        0.0
    end)
  end

  defp parse_client_horses(_), do: nil

  defp parse_js_winner(w, _horses) when is_integer(w), do: w
  defp parse_js_winner(w, _horses) when is_binary(w), do: String.to_integer(w)
  defp parse_js_winner(_, horses), do: find_winner(horses)

  defp create_horse_speeds(count) do
    for _i <- 1..count do
      base_speed = 0.8 + :rand.uniform() * 0.4
      variation = 0.1 + :rand.uniform() * 0.2
      {base_speed, variation}
    end
  end

  defp update_horse_positions(positions, horse_speeds) do
    positions
    |> Enum.with_index()
    |> Enum.map(fn {position, idx} ->
      {base_speed, variation} = Enum.at(horse_speeds, idx)

      speed_modifier =
        base_speed + if Enum.random([0, 1]) == 0, do: variation, else: -variation / 2

      increment = speed_modifier * (2 + Enum.random([0, 1, 2]))

      min(position + increment, 100)
    end)
  end

  defp find_winner(horses) do
    horses
    |> Enum.with_index()
    |> Enum.max_by(fn {position, _idx} -> position end)
    |> elem(1)
    |> (&(&1 + 1)).()
  end

  defp format_time(seconds) do
    minutes = div(seconds, 60)
    secs = rem(seconds, 60)
    minutes_str = String.pad_leading(Integer.to_string(minutes), 2, "0")
    secs_str = String.pad_leading(Integer.to_string(secs), 2, "0")
    "#{minutes_str}:#{secs_str}"
  end

  defp generate_race_id do
    timestamp = System.system_time(:millisecond)
    random = :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)
    "race-#{timestamp}-#{random}"
  end

  defp process_race_payouts(socket, winning_horse) do
    multiplier = socket.assigns.multiplier
    race_id = socket.assigns.current_race_id

    # Process only bets for the current race_id
    case Pearl.Minigames.process_horse_race_payouts(race_id, winning_horse, multiplier) do
      {:ok, %{winners: winners, losers: losers}} ->
        winner_count = length(winners)
        loser_count = length(losers)

        total_payout =
          winners
          |> Enum.map(& &1.payout_amount)
          |> Enum.reduce(Decimal.new(0), &Decimal.add/2)
          |> Decimal.to_float()

        message =
          "Payouts processed! #{winner_count} winner(s) received #{Float.round(total_payout, 3)} tokens total. #{loser_count} losing bet(s)."

        Pearl.Minigames.broadcast_horse_race_result(winning_horse)

        new_race_id = generate_race_id()
        Pearl.Minigames.cancel_stale_pending_bets(new_race_id)
        Pearl.Minigames.broadcast_horse_race_start(new_race_id)

        socket
        |> assign(current_race_id: new_race_id)
        |> put_flash(:info, message)

      {:error, reason} ->
        socket
        |> put_flash(:error, "Error processing payouts: #{inspect(reason)}")
    end
  end

  def render(assigns) do
    ~H"""
    <.page title={gettext("Horse Race Game")}>
      <:actions>
        <.link navigate={~p"/dashboard/minigames/horse_race"}>
          <.button class="m-5">
            <.icon name="hero-arrow-left" class="w-5 mr-2" />
            {gettext("Back to Config")}
          </.button>
        </.link>
      </:actions>

      <div
        class="w-full"
        phx-hook="HorseRace"
        id="horse-race-game"
        data-duration={@total_race_time}
      >
        <div class="mb-8">
          <div class="grid grid-cols-3 gap-4 mb-6">
            <div class="p-4 rounded-lg dark:bg-darkShade/20 bg-lightShade/20">
              <p class="text-sm text-gray-500">{gettext("Win Multiplier")}</p>
              <p class="text-2xl font-bold">{Float.round(@multiplier, 2)}x</p>
            </div>
            <div class="p-4 rounded-lg dark:bg-darkShade/20 bg-lightShade/20">
              <p class="text-sm text-gray-500">{gettext("Race Duration")}</p>
              <p class="text-2xl font-bold">{@duration_minutes} min</p>
            </div>
            <div class="p-4 rounded-lg dark:bg-darkShade/20 bg-lightShade/20 flex justify-between items-center">
              <div>
                <p class="text-sm text-gray-500">{gettext("Time Remaining")}</p>
                <p class="text-2xl font-bold">
                  <span class="text-green-600 dark:text-green-400" id="race-timer">
                    {format_time(@time_remaining)}
                  </span>
                </p>
              </div>
              <div class="flex gap-2">
                <.button
                  phx-click="start_race"
                  disabled={@racing || @winner != nil}
                  id="btn-start-race"
                  phx-value-duration={@total_race_time}
                  class="bg-black hover:bg-zinc-900 text-white font-bold py-2 px-4 rounded-lg shadow-lg disabled:opacity-50 disabled:cursor-not-allowed hover:scale-105 transition-all text-sm border-2 border-red-800"
                >
                  <.icon name="hero-play" class="w-5 mr-1" />
                  {gettext("Start")}
                </.button>

                <%= if @racing do %>
                  <.button
                    phx-click="stop_race"
                    id="btn-stop-race"
                    class="bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white font-bold py-2 px-4 rounded-lg shadow-lg hover:scale-105 transition-all text-sm"
                  >
                    <.icon name="hero-stop" class="w-5 mr-1" />
                    {gettext("Stop")}
                  </.button>
                <% end %>

                <%= if @winner && !@racing do %>
                  <.button
                    phx-click="reset_race"
                    id="btn-reset-race"
                    class="bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-bold py-2 px-4 rounded-lg shadow-lg hover:scale-105 transition-all animate-pulse text-sm"
                  >
                    <.icon name="hero-arrow-path" class="w-5 mr-1" />
                    {gettext("New")}
                  </.button>
                <% end %>
              </div>
            </div>
          </div>

          <div class="p-1 bg-black border-2 border-red-500 shadow-2xl relative overflow-hidden font-mono">
            <div class="mb-0.5">
              <div class="space-y-0" id="horses-container" phx-update="ignore">
                <%= for {horse, index} <- Enum.with_index(@horses) do %>
                  <div class="relative flex border-t border-red-500/40 first:border-t-0" data-lane-index={index}>
                    <div class="w-14 h-10 bg-black flex items-center justify-center font-bold text-sm border border-red-500 z-10">
                      <div class="text-white text-base">#{index + 1}</div>
                    </div>

                    <div class="relative h-10 flex-1 bg-black overflow-hidden border border-gray-600 ml-1">
                      <div class="absolute inset-0 flex">
                        <div class="flex-1 border-r border-dashed border-gray-700/80"></div>
                        <div class="flex-1 border-r border-dashed border-gray-700/80"></div>
                        <div class="flex-1 border-r border-dashed border-gray-700/80"></div>
                        <div class="flex-1 border-r border-dashed border-gray-700/80"></div>
                        <div class="flex-1 border-r border-dashed border-gray-700/80"></div>
                        <div class="flex-1 border-r border-dashed border-gray-700/80"></div>
                        <div class="flex-1 border-r border-dashed border-gray-700/80"></div>
                        <div class="flex-1"></div>
                      </div>

                      <div class="absolute inset-0 flex items-center px-2 opacity-50">
                        <div class="w-full border-t border-dashed border-gray-700/80"></div>
                      </div>

                      <div class="absolute inset-0 hidden items-center justify-center z-20 winner-banner" id={"winner-banner-#{index}"}>
                        <div class="bg-black px-6 py-1 border border-red-500 shadow-[0_0_15px_rgba(239,68,68,0.6)] flex items-center justify-center">
                          <span class="text-red-500 text-xs font-bold tracking-[0.3em]">
                            HORSE #{index + 1} WINS!
                          </span>
                        </div>
                      </div>

                      <div
                        class="absolute top-0 h-full w-8 flex items-center justify-center transition-all duration-75 horse-marker z-10"
                        id={"horse-marker-#{index}"}
                        data-horse-index={index}
                        data-position={horse}
                        style={"left: calc(#{horse}% - 8px)"}
                      >
                        <img
                          src={~p"/images/icons/horse.png"}
                          alt="Horse"
                          class="horse-icon w-7 h-7 object-contain"
                        />
                      </div>

                      <div class="absolute right-0 top-0 h-full w-8 border-l border-red-500 flex flex-col justify-between p-[2px]">
                        <%= for _ <- 1..6 do %>
                          <div class="w-full h-[2px] bg-white"></div>
                        <% end %>
                      </div>
                    </div>

                    <div class="w-14 h-10 flex items-center justify-center ml-1 bg-black border border-red-500">
                      <span
                        class="text-sm font-mono font-bold text-white horse-percentage"
                        id={"horse-percent-#{index}"}
                      >
                        {round(horse)}%
                      </span>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </.page>
    """
  end
end
