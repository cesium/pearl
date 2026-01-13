defmodule PearlWeb.Landing.FAQLive.Index do
  use PearlWeb, :landing_view

  alias Pearl.Event
  import PearlWeb.Landing.FAQLive.Components.{Faq, FindUs}

  on_mount {PearlWeb.VerifyFeatureFlag, "faqs_enabled"}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current_page, :faqs)
     |> assign(:event_start_date, Event.get_event_start_date())
     |> stream(:faqs, Event.list_faqs())}
  end
end
