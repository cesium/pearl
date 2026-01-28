defmodule PearlWeb.Landing.SpeakersLive.Index do
  use PearlWeb, :landing_view

  import PearlWeb.Landing.SpeakersLive.Components.Speakers

  alias Pearl.Activities
  alias Pearl.Event

  on_mount {PearlWeb.VerifyFeatureFlag, "speakers_enabled"}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:event_start_date, Event.get_event_start_date())
     |> assign(:event_end_date, Event.get_event_end_date())
     |> assign(:current_page, :speakers)
     |> assign(:all_speakers, Activities.list_speakers())
     |> assign(:current_filter, :name)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Activities.list_speakers(params) do
      {:ok, {speakers, meta}} ->
        {:noreply,
         socket
         |> assign(:speakers, speakers)
         |> assign(:meta, meta)
         |> assign(:params, params)}

      {_, meta} ->
        {:noreply,
         socket
         |> assign(:speakers, [])
         |> assign(:meta, meta)
         |> assign(:params, params)}
    end
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/speakers?#{params}")}
  end

  def handle_event("select-filter", %{"filter" => filter}, socket) do
    {:noreply,
     socket
     |> assign(:current_filter, String.to_existing_atom(filter))}
  end

  def handle_event("clear-filter", _params, socket) do
    {:noreply,
     socket
     |> push_patch(to: "/speakers")}
  end
end
