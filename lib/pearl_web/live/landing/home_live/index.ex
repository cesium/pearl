defmodule PearlWeb.Landing.HomeLive.Index do
  alias Pearl.Companies
  use PearlWeb, :landing_view

  import PearlWeb.Landing.HomeLive.Components.{Hero, Partners, Pitch, Sponsors, Speakers}

  alias Pearl.{Activities, Event}

  @impl true
  def mount(_params, _session, socket) do
    speakers = Activities.list_speakers_for_showcase()

    {selected_speaker, selected_activity} =
      case speakers do
        [%{speaker: speaker, activity: activity} | _] -> {speaker, activity}
        _ -> {nil, nil}
      end

    {:ok,
     socket
     |> assign(:current_page, :home)
     |> assign(:tiers, Companies.list_tiers_with_companies())
     |> assign(:event_start_date, Event.get_event_start_date())
     |> assign(:event_end_date, Event.get_event_end_date())
     |> assign(:has_highlighted_speakers?, speakers != [])
     |> assign(:registrations_open?, Event.registrations_open?())
     |> assign(:has_sponsors?, Companies.get_companies_count() > 0)
     |> assign(:has_schedule?, Activities.get_activities_count() > 0)
     |> assign(:speakers, speakers)
     |> assign(:selected_speaker, selected_speaker)
     |> assign(:selected_activity, selected_activity)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> assign(:params, params)}
  end

  @impl true
  def handle_info({:update_flash, {flash_type, msg}}, socket) do
    {:noreply, put_flash(socket, flash_type, msg)}
  end

  @impl true
  def handle_event("select_speaker", %{"speaker-id" => id}, socket) do
    found_item =
      Enum.find(socket.assigns.speakers, fn %{speaker: s} ->
        s.id == id
      end)

    case found_item do
      %{speaker: speaker, activity: activity} ->
        {:noreply,
         socket
         |> assign(:selected_speaker, speaker)
         |> assign(:selected_activity, activity)}

      nil ->
        IO.puts("Speaker with ID #{inspect(id)} not found")
        {:noreply, socket}
    end
  end
end
