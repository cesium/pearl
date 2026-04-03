defmodule PearlWeb.Backoffice.AttendeeLive.Show do
  use PearlWeb, :backoffice_view

  alias Pearl.{Accounts, Tickets}

  import PearlWeb.Components.{Button, Modal}

  on_mount {PearlWeb.StaffRoles,
            show: %{"attendees" => ["show"]}, edit: %{"attendees" => ["edit"]}}

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :attendees)}
  end

  def handle_params(%{"id" => attendee_id} = params, _, socket) do
    attendee =
      Accounts.get_attendee!(attendee_id, preloads: [:user])
      |> Pearl.Repo.preload(user: [ticket: :ticket_type])

    {:noreply,
     socket
     |> assign(:attendee, attendee)
     |> assign(:params, params)}
  end
end
