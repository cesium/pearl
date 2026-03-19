defmodule PearlWeb.Landing.TicketsLive.Index do
  use PearlWeb, :landing_view

  on_mount {PearlWeb.VerifyFeatureFlag, "tickets_enabled"}

  alias Pearl.TicketTypes
  alias Pearl.Tickets
  import PearlWeb.Landing.TicketsLive.Components.Card

  def mount(_params, _session, socket) do
    ticket_types = TicketTypes.list_active_ticket_types()
    event_ticket_types = Enum.filter(ticket_types, &(&1.type == :event))
    activity_ticket_types = Enum.filter(ticket_types, &(&1.type == :activity))

    user_ticket =
      case socket.assigns.current_user do
        nil -> nil
        user -> Tickets.get_user_ticket(user.id)
      end

    {:ok,
     socket
     |> assign(:event_ticket_types, event_ticket_types)
     |> assign(:activity_ticket_types, activity_ticket_types)
     |> assign(:user_ticket, user_ticket)
     |> assign(:current_page, :tickets)}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "select_ticket",
        %{"ticket_type_id" => ticket_type_id, "type" => "activity"},
        socket
      ) do
    {:noreply, redirect(socket, to: ~p"/checkout/activity/init?ticket_type_id=#{ticket_type_id}")}
  end

  def handle_event("select_ticket", %{"ticket_type_id" => ticket_type_id}, socket) do
    {:noreply, redirect(socket, to: ~p"/checkout/init?ticket_type_id=#{ticket_type_id}")}
  end
end
