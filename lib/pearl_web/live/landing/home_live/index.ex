defmodule PearlWeb.Landing.HomeLive.Index do
  alias Pearl.Companies
  use PearlWeb, :landing_view

  import PearlWeb.Landing.HomeLive.Components.{
    Hero,
    Sponsors,
    Activities,
    InfoSection,
    Wrapup,
    PromoCards,
    Speakers
  }

  alias Pearl.{Activities, Event}

  @impl true
  def mount(_params, _session, socket) do
    speakers = Activities.list_highlighted_speakers() |> Enum.take_random(4)

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
     |> assign(:has_sponsors?, Companies.get_companies_count() > 0)
     |> assign(:has_schedule?, Activities.get_activities_count() > 0)
     |> assign(:is_register_open?, Event.registrations_open?())
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
    {:noreply, put_flash(socket, flash_type, Gettext.gettext(PearlWeb.Gettext, msg))}
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

  @impl true
  def handle_event("cycle_speaker", _params, %{assigns: %{speakers: []}} = socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cycle_speaker", _params, %{assigns: %{selected_speaker: nil}} = socket) do
    case socket.assigns.speakers do
      [%{speaker: speaker, activity: activity} | _] ->
        {:noreply, assign_speaker(socket, speaker, activity)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("cycle_speaker", %{"direction" => direction}, socket) do
    speakers = socket.assigns.speakers
    current_speaker = socket.assigns.selected_speaker
    current_index = Enum.find_index(speakers, fn %{speaker: s} -> s.id == current_speaker.id end)
    new_index = next_index(direction, current_index, length(speakers))

    case Enum.at(speakers, new_index) do
      %{speaker: speaker, activity: activity} ->
        {:noreply, assign_speaker(socket, speaker, activity)}

      nil ->
        {:noreply, socket}
    end
  end

  defp assign_speaker(socket, speaker, activity) do
    socket
    |> assign(:selected_speaker, speaker)
    |> assign(:selected_activity, activity)
  end

  defp next_index("next", idx, count) when not is_nil(idx), do: rem(idx + 1, count)
  defp next_index("previous", idx, count) when not is_nil(idx), do: rem(idx - 1 + count, count)
  defp next_index(_direction, _idx, _count), do: 0
end
