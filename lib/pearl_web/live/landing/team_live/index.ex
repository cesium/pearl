defmodule PearlWeb.Landing.TeamLive.Index do
  use PearlWeb, :landing_view

  alias Pearl.Teams
  import PearlWeb.Landing.TeamLive.Components.{PolygonLines, Team}

  on_mount {PearlWeb.VerifyFeatureFlag, "team_enabled"}

  @impl true
  def mount(_params, _session, socket) do
    teams = Teams.list_teams(preloads: [:team_members])

    sorted_teams =
      Enum.map(teams, fn team ->
        %{team | team_members: Enum.sort_by(team.team_members, & &1.name)}
      end)

    {:ok,
     socket
     |> assign(teams: sorted_teams)
     |> assign(filter_by: :all)
     |> assign(:current_page, :team)}
  end

  @impl true
  def handle_event("add_filter", %{"filter" => "all"}, socket) do
    {:noreply,
     socket
     |> assign(filter_by: :all)}
  end

  def handle_event("add_filter", %{"filter" => filter}, socket) do
    {:noreply,
     socket
     |> assign(filter_by: if(filter != socket.assigns.filter_by, do: filter, else: :all))}
  end
end
