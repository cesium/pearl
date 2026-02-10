defmodule PearlWeb.Landing.SpeakersLive.Index do
  use PearlWeb, :landing_view

  import PearlWeb.Landing.SpeakersLive.Components.Speakers

  alias Pearl.Activities
  alias Pearl.Event

  on_mount {PearlWeb.VerifyFeatureFlag, "speakers_enabled"}

  @impl true
  def mount(_params, _session, socket) do
    speakers = Activities.list_speakers_activities()

    {:ok,
     socket
     |> assign(:event_start_date, Event.get_event_start_date())
     |> assign(:event_end_date, Event.get_event_end_date())
     |> assign(:current_page, :speakers)
     |> assign(:all_speakers, speakers)
     |> assign(:speakers, speakers)
     |> assign(:current_value, nil)
     |> assign(:current_filter, :name)}
  end

  @impl true
  def handle_event("update-filter", %{"name" => initial}, socket) do
    speakers = socket.assigns.all_speakers |> filter_by_initial(initial)

    {:noreply,
     socket
     |> assign(:current_value, initial)
     |> assign(:speakers, speakers)}
  end

  def handle_event("update-filter", %{"activity-date" => date}, socket) do
    speakers = socket.assigns.all_speakers |> filter_by_date(date)

    {:noreply,
     socket
     |> assign(:current_value, date)
     |> assign(:speakers, speakers)}
  end

  def handle_event("select-filter", %{"filter" => filter}, socket) do
    {:noreply,
     socket
     |> assign(:current_filter, String.to_existing_atom(filter))
     |> assign(:current_value, nil)
     |> assign(:speakers, socket.assigns.all_speakers)}
  end

  def handle_event("clear-filter", _params, socket) do
    {:noreply,
     socket
     |> assign(:current_value, nil)
     |> assign(:speakers, socket.assigns.all_speakers)}
  end

  defp filter_by_initial(speakers, initial) do
    speakers |> Enum.filter(fn %{speaker: speaker} -> String.first(speaker.name) == initial end)
  end

  defp filter_by_date(speakers, date) do
    speakers
    |> Enum.filter(fn %{activity: activity} ->
      activity && to_string(activity.date) == date
    end)
  end
end
