defmodule PearlWeb.Backoffice.MinigamesLive.HorseRace.Index do
  @moduledoc false
  use PearlWeb, :live_component

  alias Pearl.Minigames

  def render(assigns) do
    ~H"""
    <div
      class="w-full"
      phx-hook="HorseRace"
      id="horse-race-game"
      phx-target={@myself}
      data-cid={@myself.cid}
      data-duration={@total_race_time}
    >
      <div class="mb-8">
        <h2 class="text-2xl font-bold mb-4">{gettext("Horse Race Game")}</h2>

        <div class="grid grid-cols-4 gap-4 mb-6">
          <div class="p-4 rounded-lg dark:bg-darkShade/20 bg-lightShade/20">
            <p class="text-sm text-gray-500">{gettext("Entry Fee")}</p>
            <p class="text-2xl font-bold">{@entry_fee} tokens</p>
          </div>
          <div class="p-4 rounded-lg dark:bg-darkShade/20 bg-lightShade/20">
            <p class="text-sm text-gray-500">{gettext("Win Multiplier")}</p>
            <p class="text-2xl font-bold">{Float.round(@multiplier, 2)}x</p>
          </div>
          <div class="p-4 rounded-lg dark:bg-darkShade/20 bg-lightShade/20">
            <p class="text-sm text-gray-500">{gettext("Race Duration")}</p>
            <p class="text-2xl font-bold">{@duration_minutes} min</p>
          </div>
          <div class="p-4 rounded-lg dark:bg-darkShade/20 bg-lightShade/20">
            <p class="text-sm text-gray-500">{gettext("Time Remaining")}</p>
            <p class="text-2xl font-bold">
              <span class="text-green-600 dark:text-green-400" id="race-timer">
                {format_time(@time_remaining)}
              </span>
            </p>
          </div>
        </div>

        <div class="p-6 bg-[#811824] rounded-xl border-2 border-[#ffdb0d]/50 shadow-2xl relative overflow-hidden">
          <div class="mb-6">
            <h3 class="text-2xl font-bold mb-4 text-[#ffdb0d] uppercase tracking-wider">
              {gettext("Race Track")}
            </h3>

            <div class="mb-4 w-full h-2 bg-gray-300 dark:bg-gray-600 rounded-full overflow-hidden">
              <div
                class="h-full bg-linear-to-r from-purple-500 to-pink-500 transition-all duration-300"
                id="race-progress-bar"
                style={"width: #{div(@time_elapsed * 100, @total_race_time)}%"}
              >
              </div>
            </div>

            <div class="space-y-3" id="horses-container">
              <%= for {horse, index} <- Enum.with_index(@horses) do %>
                <div class="relative">
                  <div class="absolute left-0 top-0 h-full w-16 bg-black/40 flex flex-col items-center justify-center font-bold text-sm border-r-2 border-[#ffdb0d]/50 rounded-l-lg z-10">
                    <div class="text-[#ffdb0d] text-xl font-black">##{index + 1}</div>
                    <div class="text-white text-xs mt-1">Lane</div>
                  </div>

                  <div class="relative h-16 bg-[#f8f9fa] rounded-lg overflow-hidden border-2 border-[#ffdb0d]/50 ml-16 shadow-inner">
                    <div class="absolute inset-0 flex">
                      <div class="flex-1 border-r-2 border-dashed border-black/10"></div>
                      <div class="flex-1 border-r-2 border-dashed border-black/10"></div>
                      <div class="flex-1 border-r-2 border-dashed border-black/10"></div>
                    </div>

                    <div
                      class="absolute top-0 h-full w-8 flex items-center justify-center text-2xl transition-all duration-75 animate-bounce horse-marker"
                      id={"horse-marker-#{index}"}
                      data-horse-index={index}
                      style={"left: calc(#{horse}%)"}
                    >
                      <img
                        src={~p"/images/icons/horse.png"}
                        alt="Horse"
                        class="w-10 h-10 animate-bounce horse-icon"
                      />
                    </div>

                    <div class="absolute right-0 top-0 h-full w-2 bg-gradient-to-b from-[#ffdb0d] via-yellow-400 to-[#ffdb0d] finish-line shadow-lg shadow-[#ffdb0d]/50">
                    </div>
                  </div>

                  <div class="absolute right-2 top-0 h-full flex items-center">
                    <div class="bg-black/90 border-2 border-[#ffdb0d] rounded px-2 py-1 shadow-lg mr-2">
                      <span
                        class="text-sm font-mono font-bold text-[#ffdb0d] horse-percentage"
                        id={"horse-percent-#{index}"}
                      >
                        {round(horse)}%
                      </span>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>

            <div class="mt-6 flex gap-4">
              <.button
                phx-click="start_race"
                phx-target={@myself}
                disabled={@racing}
                id="btn-start-race"
                phx-value-duration={@total_race_time}
                class="bg-[#ffdb0d] hover:bg-yellow-400 text-[#811824] font-black py-2 px-6 rounded-lg shadow-lg transform hover:scale-105 transition-all border-2 border-[#811824]"
              >
                <.icon name="hero-play" class="w-5 mr-2" />
                {gettext("Start Race")}
              </.button>

              <%= if @racing do %>
                <.button
                  phx-click="stop_race"
                  phx-target={@myself}
                  id="btn-stop-race"
                  class="bg-red-600 hover:bg-red-700 text-white font-bold py-2 px-4 rounded"
                >
                  <.icon name="hero-stop" class="w-5 mr-2" />
                  {gettext("Stop Race")}
                </.button>
              <% end %>
            </div>
          </div>

          <%= if @winner do %>
            <div
              class="absolute inset-0 z-50 flex items-center justify-center bg-dark/80 backdrop-blur-md rounded-xl"
              phx-hook="Confetti"
              id="backoffice-horse-race-result"
              data-is_win="true"
            >
              <div class="relative p-10 w-11/12 max-w-2xl bg-darkShade border border-white/10 rounded-3xl shadow-2xl text-center animate-in zoom-in duration-300 overflow-hidden">
                <div class="absolute top-0 left-1/2 -translate-x-1/2 w-full h-1/2 bg-primary/20 blur-[100px] pointer-events-none">
                </div>

                <div class="relative z-10 flex flex-col items-center">
                  <div class="inline-flex items-center justify-center w-20 h-20 rounded-full bg-primary/10 border border-primary/20 mb-6 shadow-lg shadow-primary/20">
                    <img
                      src={~p"/images/icons/horse.png"}
                      alt="Winner"
                      class="w-10 h-10 brightness-0 invert opacity-90 animate-bounce"
                    />
                  </div>

                  <h3 class="font-grotesk text-sm font-semibold tracking-widest text-lightMuted uppercase mb-3">
                    {gettext("Fim da Corrida")}
                  </h3>

                  <p class="font-grotesk text-4xl md:text-5xl font-bold text-light mb-8 drop-shadow-md">
                    {gettext("O cavalo")}
                    <span class="text-accent">{@winner}</span> {gettext("venceu!")}
                  </p>

                  <button
                    phx-click="clear_winner"
                    phx-target={@myself}
                    class="inline-flex items-center justify-center px-8 py-3 bg-light hover:bg-light/90 text-dark font-grotesk font-semibold text-lg rounded-full transition-transform hover:scale-105 shadow-lg shadow-light/10"
                  >
                    {gettext("Fechar Painel")}
                  </button>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def mount(socket) do
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
    racing = Minigames.horse_race_running?()

    socket =
      socket
      |> assign(
        is_active: Minigames.horse_race_active?(),
        multiplier: Minigames.get_horse_race_multiplier(),
        duration_minutes: duration_minutes,
        number_of_horses: number_of_horses,
        house_fee: Minigames.get_horse_race_house_fee(),
        horses: List.duplicate(0, number_of_horses),
        horse_speeds: horse_speeds,
        racing: racing,
        winner: nil,
        time_remaining: total_race_time,
        time_elapsed: 0,
        total_race_time: total_race_time,
        race_start_time: if(racing, do: System.monotonic_time(:millisecond), else: nil)
      )

    socket =
      if racing, do: push_event(socket, "start_race", %{duration: total_race_time}), else: socket

    {:ok, socket}
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
    duration = String.to_integer(params["duration"] || "#{socket.assigns.total_race_time}")

    Minigames.set_horse_race_running(true)

    socket =
      socket
      |> assign(
        racing: true,
        winner: nil,
        horses: List.duplicate(0, number_of_horses),
        horse_speeds: horse_speeds,
        time_remaining: socket.assigns.total_race_time,
        time_elapsed: 0,
        race_start_time: System.monotonic_time(:millisecond)
      )
      |> push_event("start_race", %{duration: duration})

    {:noreply, socket}
  end

  def handle_event("clear_winner", _params, socket) do
    {:noreply, assign(socket, winner: nil)}
  end

  def handle_event("stop_race", _params, socket) do
    Minigames.set_horse_race_running(false)

    socket =
      socket
      |> assign(racing: false)
      |> push_event("stop_race", %{})

    {:noreply, socket}
  end

  def handle_event("reset_race", _params, socket) do
    number_of_horses = socket.assigns.number_of_horses

    Minigames.set_horse_race_running(false)

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

    {:noreply, socket}
  end

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

  def handle_update(%{update: "update_race", params: params}, socket) do
    if socket.assigns.racing do
      {:ok, process_update_race(socket, params)}
    else
      {:ok, socket}
    end
  end

  def handle_update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  defp process_update_race(socket, params) do
    elapsed = parse_elapsed(params["elapsed"])
    time_remaining = max(0, socket.assigns.total_race_time - elapsed)
    client_horses = parse_client_horses(params["positions"])

    if elapsed >= socket.assigns.total_race_time do
      finish_race(socket, client_horses, params["js_winner"])
    else
      continue_race(socket, elapsed, time_remaining, client_horses)
    end
  end

  defp finish_race(socket, client_horses, js_winner) do
    horses = client_horses || Enum.map(socket.assigns.horses, &min(&1, 100))
    winner = parse_js_winner(js_winner, horses)

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
      client_horses ||
        update_horse_positions(socket.assigns.horses, socket.assigns.horse_speeds)

    winner =
      if Enum.any?(new_horses, &(&1 >= 100)), do: find_winner(new_horses), else: nil

    assign(socket,
      horses: new_horses,
      time_remaining: time_remaining,
      time_elapsed: elapsed,
      racing: is_nil(winner)
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

end
