defmodule PearlWeb.Backoffice.MinigamesLive.Index do
  use PearlWeb, :backoffice_view

  on_mount {PearlWeb.StaffRoles,
            index: %{"minigames" => ["show"]},
            simulate_wheel: %{"minigames" => ["simulate"]},
            edit_wheel_drops: %{"minigames" => ["edit"]},
            edit_wheel: %{"minigames" => ["edit"]},
            edit_slots: %{"minigames" => ["edit"]},
            edit_slots_reel_icons_icons: %{"minigames" => ["edit"]},
            edit_slots_paytable: %{"minigames" => ["edit"]},
            edit_slots_payline: %{"minigames" => ["edit"]},
            edit_coin_flip: %{"minigames" => ["edit"]},
            edit_horse_race: %{"minigames" => ["edit"]},
            horse_race: %{"minigames" => ["edit"]}}

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :minigames)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("update_race", params, socket) do
    send_update(
      PearlWeb.Backoffice.MinigamesLive.HorseRace.Index,
      id: "horse-race-game",
      update: "update_race",
      params: params
    )

    {:noreply, socket}
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end
end
