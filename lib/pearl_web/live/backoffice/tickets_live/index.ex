defmodule PearlWeb.Backoffice.TicketsLive.Index do
  use PearlWeb, :backoffice_view

  import PearlWeb.Components.{Table, TableSearch}

  alias Pearl.{Perks, Tickets, TicketTypes}
  alias Pearl.Tickets.{Perk, TicketType}

  on_mount {PearlWeb.StaffRoles,
            index: %{"tickets" => ["show"]},
            new: %{"tickets" => ["edit"]},
            edit: %{"tickets" => ["edit"]},
            ticket_types: %{"tickets" => ["ticket_types_show"]},
            ticket_types_new: %{"tickets" => ["ticket_types_edit"]},
            ticket_types_edit: %{"tickets" => ["ticket_types_edit"]},
            perks: %{"tickets" => ["perks_show"]},
            perks_new: %{"tickets" => ["perks_show"]},
            perks_edit: %{"tickets" => ["perks_edit"]}}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    case Tickets.list_tickets(params) do
      {:ok, {tickets, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :tickets)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:tickets, tickets, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tickets")
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ticket")
    |> assign(:ticket, Tickets.get_ticket!(id))
  end

  defp apply_action(socket, :ticket_types, _params) do
    socket
    |> assign(:page_title, "Listing Ticket Types")
  end

  defp apply_action(socket, :ticket_types_edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ticket Type")
    |> assign(:ticket_type, TicketTypes.get_ticket_type!(id))
  end

  defp apply_action(socket, :ticket_types_new, _params) do
    socket
    |> assign(:page_title, "New Ticket Type")
    |> assign(:ticket_type, %TicketType{})
  end

  defp apply_action(socket, :perks, _params) do
    socket
    |> assign(:page_title, "Listing Perks")
  end

  defp apply_action(socket, :perks_new, _params) do
    socket
    |> assign(:page_title, "New Perk")
    |> assign(:perk, %Perk{})
  end

  defp apply_action(socket, :perks_edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Perk")
    |> assign(:perk, Perks.get_perk!(id))
  end

  def handle_event("delete", %{"id" => id}, socket) do
    ticket = Tickets.get_ticket!(id)
    {:ok, _} = Tickets.delete_ticket(ticket)

    {:noreply, stream_delete(socket, :tickets, ticket)}
  end
end
