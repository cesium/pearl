defmodule PearlWeb.Landing.TicketsLive.Index do
  use PearlWeb, :landing_view

  on_mount {PearlWeb.VerifyFeatureFlag, "tickets_enabled"}

  alias Pearl.TicketTypes
  import PearlWeb.Landing.TicketsLive.Components.Card

  def mount(_params, _session, socket) do
    ticket_types = TicketTypes.list_active_ticket_types()

    {:ok, socket |> assign(:ticket_types, ticket_types)}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("select_ticket", %{"ticket_type_id" => ticket_type_id}, socket) do
    {:noreply,
     socket
     |> push_navigate(to: ~p"/checkout/init?ticket_type_id=#{ticket_type_id}")}
  end
end
