defmodule PearlWeb.Landing.HomeLive.Index do
  alias Pearl.Companies
  use PearlWeb, :landing_view

  import PearlWeb.Landing.HomeLive.Components.{Hero, Partners, Pitch, Sponsors, Speakers}

  alias Pearl.{Activities, Event}

  @impl true
  def mount(_params, _session, socket) do
    speakers = Activities.list_highlighted_speakers()
    first_speaker = List.first(speakers)

    speakers_with_selection =
      Enum.map(speakers, fn s ->
        Map.put(s, :selected, first_speaker && s.id == first_speaker.id)
      end)

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
     |> assign(:selected_speaker, first_speaker)
     |> stream(:speakers, speakers_with_selection)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> assign(:params, params)}
  end

  @impl true
  def handle_event("select_speaker", %{"id" => id}, socket) do
    speaker = Activities.get_speaker!(id)

    # Update streams to reflect selection
    speakers = Activities.list_highlighted_speakers()

    speakers_with_selection =
      Enum.map(speakers, fn s ->
        Map.put(s, :selected, s.id == speaker.id)
      end)

    {:noreply,
     socket
     |> assign(:selected_speaker, speaker)
     |> stream(:speakers, speakers_with_selection, reset: true)}
  end

  @impl true
  def handle_info({:update_flash, {flash_type, msg}}, socket) do
    {:noreply, put_flash(socket, flash_type, msg)}
  end
end
