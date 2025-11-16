defmodule PearlWeb.Landing.SpeakersLive.Index do
  use PearlWeb, :landing_view

  import PearlWeb.Landing.SpeakersLive.Components.Speakers

  alias Pearl.Event

  on_mount {PearlWeb.VerifyFeatureFlag, "speakers_enabled"}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:event_start_date, Event.get_event_start_date())
     |> assign(:event_end_date, Event.get_event_end_date())
     |> assign(:current_page, :speakers)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> assign(:params, params)}
  end
end
