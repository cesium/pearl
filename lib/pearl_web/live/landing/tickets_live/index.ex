defmodule PearlWeb.Landing.TicketsLive.Index do
  use PearlWeb, :landing_view

  on_mount {PearlWeb.VerifyFeatureFlag, "tickets_enabled"}

  import PearlWeb.Landing.TicketsLive.Components.Card

  alias Pearl.TicketTypes

  def mount(_params, _session, socket) do
    ticket_types = TicketTypes.list_ticket_types()

    {:ok, socket |> assign(:ticket_types, ticket_types)}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end
end
