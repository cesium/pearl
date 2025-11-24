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

        <div class="p-6 bg-linear-to-b dark:from-darkShade/30 dark:to-darkShade/10 from-lightShade/30 to-lightShade/10 rounded-lg border-2 dark:border-darkShade/20 border-lightShade/20">
          <div class="mb-6">
            <h3 class="text-xl font-bold mb-4">{gettext("Race Track")}</h3>

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
                  <div class="absolute left-0 top-0 h-full w-16 dark:bg-darkShade/50 bg-lightShade/50 flex flex-col items-center justify-center font-bold text-sm border-r dark:border-darkShade/20 border-lightShade/20 rounded-l">
                    <div>🐴</div>
                    <div class="text-xs">#{index + 1}</div>
                  </div>

                  <div class="relative h-16 dark:bg-darkShade/30 bg-lightShade/30 rounded-lg overflow-hidden border dark:border-darkShade/20 border-lightShade/20 ml-16">
                    <div class="absolute inset-0 flex">
                      <div class="flex-1 border-r dark:border-darkShade/10 border-lightShade/10">
                      </div>
                      <div class="flex-1 border-r dark:border-darkShade/10 border-lightShade/10">
                      </div>
                      <div class="flex-1 border-r dark:border-darkShade/10 border-lightShade/10">
                      </div>
                    </div>

                    <div
                      class="absolute top-0 h-full w-8 flex items-center justify-center text-2xl transition-all duration-75 animate-bounce horse-marker"
                      id={"horse-marker-#{index}"}
                      data-horse-index={index}
                      style={"left: calc(#{horse}%)"}
                    >
                      <%= if horse >= 95 do %>
                        <span class="text-3xl">🏇</span>
                      <% else %>
                        <span class="text-3xl">🐎</span>
                      <% end %>
                    </div>

                    <div class="absolute right-0 top-0 h-full w-1 dark:bg-red-500 bg-red-600 finish-line"></div>
                  </div>

                  <div class="absolute right-2 top-0 h-full flex items-center">
                    <span
                      class="text-sm font-bold dark:text-gray-300 text-gray-700 horse-percentage"
                      id={"horse-percent-#{index}"}
                    >
                      {round(horse)}%
                    </span>
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
                class="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded"
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
            <div class="mt-6 p-6 bg-linear-to-r from-yellow-200 to-yellow-100 dark:from-yellow-900/60 dark:to-yellow-900/30 border-l-4 border-yellow-500 rounded-lg shadow-xl winner-announcement">
              <div class="text-center">
                <div class="text-6xl mb-4 animate-bounce">🏆</div>
                <p class="font-bold text-2xl text-yellow-900 dark:text-yellow-200 mb-2">
                  🐎 {gettext("Cavalo #%{horse} venceu a corrida! 🐎", horse: @winner)}
                </p>
                <p class="text-lg mt-2 text-yellow-800 dark:text-yellow-300">
                  {gettext("Os pagamentos seriam calculados com base nas apostas feitas.")}
                </p>
                <div class="mt-4 text-5xl animate-pulse">🏇🎉</div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
      <h1>Nota ver se mudo isto do style para o hook</h1>

      <style>
        @keyframes bounce-custom {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-4px); }
        }
        .animate-bounce {
          animation: bounce-custom 0.6s infinite;
        }
      </style>
    </div>
    """
  end

  def mount(socket) do
    number_of_horses = Minigames.get_horse_race_number_of_horses()
    duration_minutes = Minigames.get_horse_race_duration()
    total_race_time = duration_minutes * 60

    horse_speeds = create_horse_speeds(number_of_horses)

    {:ok,
     socket
     |> assign(
       is_active: Minigames.horse_race_active?(),
       multiplier: Minigames.get_horse_race_multiplier(),
       duration_minutes: duration_minutes,
       entry_fee: Minigames.get_horse_race_entry_fee(),
       number_of_horses: number_of_horses,
       house_fee: Minigames.get_horse_race_house_fee(),
       horses: List.duplicate(0, number_of_horses),
       horse_speeds: horse_speeds,
       racing: false,
       winner: nil,
       time_remaining: total_race_time,
       time_elapsed: 0,
       total_race_time: total_race_time,
       race_start_time: nil
     )}
  end

  def handle_event("start_race", params, socket) do
    number_of_horses = socket.assigns.number_of_horses
    horse_speeds = create_horse_speeds(number_of_horses)
    duration = String.to_integer(params["duration"] || "#{socket.assigns.total_race_time}")

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

  def handle_event("stop_race", _params, socket) do
    socket =
      socket
      |> assign(racing: false)
      |> push_event("stop_race", %{})

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
      elapsed = String.to_integer(params["elapsed"])
      time_remaining = max(0, socket.assigns.total_race_time - elapsed)

      if elapsed >= socket.assigns.total_race_time do
        horses = Enum.map(socket.assigns.horses, &min(&1, 100))
        winner = if Enum.any?(horses, &(&1 >= 100)), do: find_winner(horses), else: nil

        {:ok,
         assign(socket,
           horses: horses,
           racing: false,
           winner: winner,
           time_remaining: 0,
           time_elapsed: socket.assigns.total_race_time
         )}
      else
        new_horses =
          update_horse_positions(socket.assigns.horses, socket.assigns.horse_speeds)

        winner =
          if Enum.any?(new_horses, &(&1 >= 100)), do: find_winner(new_horses), else: nil

        socket =
          assign(socket,
            horses: new_horses,
            time_remaining: time_remaining,
            time_elapsed: elapsed,
            racing: is_nil(winner)
          )

        {:ok, socket}
      end
    else
      {:ok, socket}
    end
  end

  def handle_update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
