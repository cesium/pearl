defmodule PearlWeb.Landing.TicketsLive.Index do
  use PearlWeb, :landing_view

  on_mount {PearlWeb.VerifyFeatureFlag, "tickets_enabled"}

  alias Pearl.Tickets
  alias Pearl.TicketTypes
  import PearlWeb.Landing.TicketsLive.Components.Card

  def mount(_params, _session, socket) do
    ticket_types = TicketTypes.list_active_ticket_types()
    event_ticket_types = Enum.filter(ticket_types, &(&1.type == :event))
    activity_ticket_types = Enum.filter(ticket_types, &(&1.type == :activity))

    user_event_ticket =
      case socket.assigns.current_user do
        nil ->
          nil

        user ->
          t = Tickets.get_user_ticket(user.id)

          cond do
            is_nil(t) -> nil
            Map.get(t, :paid) != true -> nil
            Map.get(t, :ticket_type) && t.ticket_type.type == :event -> t
            true -> nil
          end
      end

    user_activity_tickets =
      case socket.assigns.current_user do
        nil ->
          []

        user ->
          import Ecto.Query, only: [from: 2]

          from(a in Pearl.Activities.ActivityTicket,
            where: a.user_id == ^user.id,
            preload: [:ticket_type]
          )
          |> Pearl.Repo.all()
      end

    {:ok,
     socket
     |> assign(:event_ticket_types, event_ticket_types)
     |> assign(:activity_ticket_types, activity_ticket_types)
     |> assign(:user_event_ticket, user_event_ticket)
     |> assign(:user_activity_tickets, user_activity_tickets)
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
