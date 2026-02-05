defmodule PearlWeb.Backoffice.AttendeeLive.Index do
  alias Pearl.Accounts
  use PearlWeb, :backoffice_view

  import PearlWeb.Components.{Table, TableSearch, Button, InfoDisplay}

  alias Pearl.Accounts

  on_mount {PearlWeb.StaffRoles,
            index: %{"attendees" => ["show"]}, edit: %{"attendees" => ["edit"]}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    case Accounts.list_attendees(params) do
      {:ok, {attendees, meta}} ->
        {:noreply,
         socket
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> assign(:info_items, get_info_items())
         |> assign(:current_page, :attendees)
         |> stream(:attendees, attendees, reset: true)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp get_info_items do
    ticket_count = Accounts.count_attendees()
    attendees_with_tickets = Accounts.count_attendees_with_ticket()
    attendees_with_paid_tickets = Accounts.count_attendees_with_paid_ticket()

    [
      %{label: "Attendees", value: ticket_count},
      %{label: "Attendees c/ Bilhete", value: attendees_with_tickets},
      %{label: "Attendees c/ Bilhete Pago", value: attendees_with_paid_tickets}
    ]
  end
end
