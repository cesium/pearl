defmodule PearlWeb.Landing.TicketsLive.Index do
  use PearlWeb, :landing_view

    on_mount {PearlWeb.VerifyFeatureFlag, "tickets_enabled"}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

end
