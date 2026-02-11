defmodule PearlWeb.Landing.ChallengesLive.Index do
  @moduledoc false
  use PearlWeb, :landing_view

  alias Pearl.Challenges

  import PearlWeb.Landing.ChallengesLive.Components.Hero
  import PearlWeb.Landing.ChallengesLive.Components.ChallengesList
  import PearlWeb.Landing.ChallengesLive.Components.ChallengeDetail

  on_mount {PearlWeb.VerifyFeatureFlag, "challenges_enabled"}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :current_page, :challenges)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    challenges = Challenges.list_challenges()

    {:noreply,
     socket
     |> assign(:challenges, challenges)
     |> assign(:selected_challenge, Enum.at(challenges, 0))
     |> assign(:mobile_selected_challenge, nil)}
  end

  @impl true
  def handle_event("challenge_change", %{"challenge_id" => challenge_id}, socket) do
    {:noreply,
     socket
     |> assign(
       :selected_challenge,
       Enum.find(socket.assigns.challenges, fn c -> c.id == challenge_id end)
     )}
  end

  @impl true
  def handle_event("mobile_select_challenge", %{"challenge_id" => challenge_id}, socket) do
    {:noreply,
     socket
     |> assign(
       :mobile_selected_challenge,
       Enum.find(socket.assigns.challenges, fn c -> c.id == challenge_id end)
     )}
  end

  @impl true
  def handle_event("mobile_back", _params, socket) do
    {:noreply, assign(socket, :mobile_selected_challenge, nil)}
  end
end
