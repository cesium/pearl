defmodule PearlWeb.App.GamesLive.Index do
  use PearlWeb, :app_view

  import PearlWeb.App.GamesLive.Components.GameCard

  @impl true
  def mount(_params, _session, socket) do
    games = [
      %{
        name: "Lucky Whell",
        icon: "wheel.svg",
        path: "wheel",
        desc: "Spin the wheel and win exciting prizes"
      },
      %{name: "Slots", icon: "slots.svg", path: "slots", desc: "..."},
      %{name: "Coin Flip", icon: "coin-flip.svg", path: "coin_flip", desc: "..."},
      %{name: "Scratch Card", icon: "wheel.svg", path: "scratch_card", desc: "..."}
    ]

    {:ok,
     socket
     |> assign(current_page: :games)
     |> assign(games: games)}
  end
end
