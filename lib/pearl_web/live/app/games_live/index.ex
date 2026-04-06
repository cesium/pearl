defmodule PearlWeb.App.GamesLive.Index do
  use PearlWeb, :app_view

  import PearlWeb.App.GamesLive.Components.GameCard

  @impl true
  def mount(_params, _session, socket) do
    games = [
      %{
        name: "Lucky Wheel",
        icon: "wheel.svg",
        path: "wheel",
        desc: "Gira a roda e testa a tua sorte para ganhar prémios emocionantes"
      },
      %{
        name: "Slots",
        icon: "slots.svg",
        path: "slots",
        desc: "Experimenta a tua sorte com as clássicas slot machines"
      },
      %{
        name: "Coin Flip",
        icon: "coin-flip.svg",
        path: "coin_flip",
        desc: "Cara ou coroa? Desafia outros jogadores num lançamento de moeda"
      },
      %{
        name: "Scratch Card",
        icon: "ticket.svg",
        path: "scratch_card",
        desc: "Scratch, scratch, scratch e revela a tua fortuna escondida"
      }
    ]

    {:ok,
     socket
     |> assign(current_page: :games)
     |> assign(games: games)}
  end
end
