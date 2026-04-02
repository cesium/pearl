defmodule Pearl.Minigames.HorseRace.Ticker do
  @moduledoc """
  GenServer responsible for ticking the horse race simulation and broadcasting
  positions to connected LiveViews, replacing the client-side JavaScript simulation.
  """
  use GenServer

  # ms
  @tick_interval 100

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_race(race_id, duration_seconds, horse_speeds) do
    GenServer.cast(__MODULE__, {:start_race, race_id, duration_seconds, horse_speeds})
  end

  def stop_race do
    GenServer.cast(__MODULE__, :stop_race)
  end

  @impl true
  def init(_opts) do
    {:ok,
     %{
       race_id: nil,
       timer: nil,
       positions: [],
       horse_speeds: [],
       duration_seconds: 0,
       elapsed_ticks: 0,
       countdown_ticks: 30,
       running: false
     }}
  end

  @impl true
  def handle_cast({:start_race, race_id, duration_seconds, horse_speeds}, state) do
    if state.timer, do: :timer.cancel(state.timer)

    {:ok, timer} = :timer.send_interval(@tick_interval, :tick)

    # Seed RNG to the Ticker process so we can generate random speed factors reliably
    :rand.seed(:exsplus)

    positions = List.duplicate(0, length(horse_speeds))

    new_state =
      Map.merge(state, %{
        race_id: race_id,
        timer: timer,
        positions: positions,
        horse_speeds: horse_speeds,
        duration_seconds: duration_seconds,
        elapsed_ticks: 0,
        countdown_ticks: 30,
        running: true
      })

    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:stop_race, state) do
    if Map.get(state, :timer), do: :timer.cancel(state.timer)
    {:noreply, Map.merge(state, %{running: false, timer: nil})}
  end

  @impl true
  def handle_info(:tick, %{running: true, countdown_ticks: countdown} = state)
      when countdown > 0 do
    Phoenix.PubSub.broadcast(
      Pearl.PubSub,
      "horse_race_positions:#{state.race_id}",
      {:horse_race_positions, state.race_id, state.positions, false, state.duration_seconds}
    )

    {:noreply, Map.put(state, :countdown_ticks, countdown - 1)}
  end

  def handle_info(:tick, %{running: true} = state) do
    elapsed_time = state.elapsed_ticks * @tick_interval / 1000.0

    time_remaining = max(0.0, state.duration_seconds - elapsed_time)

    time_progress =
      if state.duration_seconds > 0, do: elapsed_time / state.duration_seconds, else: 1.0

    new_positions =
      update_horse_positions(
        state.positions,
        state.horse_speeds,
        time_progress,
        state.duration_seconds
      )

    finished = Enum.any?(new_positions, &(&1 >= 100)) or elapsed_time >= state.duration_seconds

    # Broadcast positions back to the LiveView instances
    Phoenix.PubSub.broadcast(
      Pearl.PubSub,
      "horse_race_positions:#{state.race_id}",
      {:horse_race_positions, state.race_id, new_positions, finished, time_remaining}
    )

    if finished do
      if Map.get(state, :timer), do: :timer.cancel(state.timer)
      {:noreply, Map.merge(state, %{positions: new_positions, running: false, timer: nil})}
    else
      {:noreply,
       Map.merge(state, %{positions: new_positions, elapsed_ticks: state.elapsed_ticks + 1})}
    end
  end

  def handle_info(:tick, state) do
    if Map.get(state, :timer), do: :timer.cancel(state.timer)
    {:noreply, Map.put(state, :timer, nil)}
  end

  defp update_horse_positions(positions, horse_speeds, time_progress, _duration_seconds) do
    positions
    |> Enum.zip(horse_speeds)
    |> Enum.map(fn {pos, {base_speed, variation}} ->
      base_position = time_progress * base_speed * 85
      random_factor = (:rand.uniform() - 0.5) * variation * 3

      surge =
        if time_progress > 0.5,
          do: :rand.uniform() * 10 * ((time_progress - 0.5) / 0.5),
          else: 0

      sprint =
        if time_progress > 0.7,
          do: :rand.uniform() * 8 * ((time_progress - 0.7) / 0.3),
          else: 0

      final_push =
        if time_progress > 0.9,
          do: :rand.uniform() * 12 * ((time_progress - 0.9) / 0.1),
          else: 0

      new_pos = base_position + random_factor + surge + sprint + final_push
      new_pos = max(pos, new_pos)

      # We cap at 100 internally here, though JS might handle overflow gracefully
      min(new_pos, 100)
    end)
  end
end
