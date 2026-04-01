defmodule PearlWeb.Backoffice.ScannerLive.TicketsLive.Index do
  use PearlWeb, :backoffice_view

  alias Pearl.{Accounts, Tickets}
  alias Pearl.Repo

  import PearlWeb.Components.{Modal}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="-translate-y-4 sm:translate-y-0">
        <.page>
          <div class="absolute flex justify-center inset-0 z-10 top-20 select-none">
            <span class="bg-dark text-light dark:bg-light dark:text-dark py-4 px-6 rounded-full font-semibold text-xl h-min">
              {gettext("Checking ticket type")}
            </span>
          </div>
          <div
            id="qr-scanner"
            phx-hook="QrScanner"
            data-ask_perm="permission-button"
            data-open_on_mount
            data-on_start="document.getElementById('scan-info').style.display = 'none'"
            data-on_success="scan"
            class="relative"
          >
          </div>
          <div id="scan-info" class="flex flex-col items-center gap-8 text-center py-40">
            <p id="loadingMessage">
              {gettext("Unable to access camera.")}
              {gettext(
                "Make sure you allow the use of your camera on this browser and that it isn't being used elsewhere."
              )}
            </p>
            <.backoffice_button id="permission-button" type="button">
              {gettext("Request Permission")}
            </.backoffice_button>
          </div>
        </.page>
      </div>

      <.modal
        :if={@modal_data != nil}
        id="modal-scan-ticket"
        show
        on_cancel={JS.push("close-modal")}
        wrapper_class="px-4"
      >
        <div class="flex flex-row gap-4 items-center">
          <%= case @modal_data do %>
            <% {:ticket, ticket} -> %>
              <div class="flex flex-col gap-4">
                <div class="flex items-center gap-4">
                  <.icon name="hero-check-circle" class="text-green-500 w-8" />
                  <div>
                    <p class="font-semibold"><%= ticket.ticket_type.name %></p>
                    <p class="text-sm text-muted">{gettext("Status: %{status}", status: if(ticket.paid, do: gettext("Paid"), else: gettext("Pending")))}</p>
                  </div>
                </div>

                <div>
                  <p class="font-semibold">{gettext("Perks")}</p>
                  <ul class="list-disc ml-6">
                    <%= for perk <- ticket.ticket_type.perks || [] do %>
                      <li><%= perk.name %></li>
                    <% end %>
                  </ul>
                </div>
              </div>

            <% :no_ticket -> %>
              <div class="flex items-center gap-4">
                <.icon name="hero-x-circle" class="text-red-500 w-8" />
                <p>{error_message(:no_ticket)}</p>
              </div>

            <% :not_found -> %>
              <div class="flex items-center gap-4">
                <.icon name="hero-x-circle" class="text-red-500 w-8" />
                <p>{error_message(:not_found)}</p>
              </div>

            <% :not_linked -> %>
              <div class="flex items-center gap-4">
                <.icon name="hero-x-circle" class="text-red-500 w-8" />
                <p>{error_message(:not_linked)}</p>
              </div>

            <% :invalid -> %>
              <div class="flex items-center gap-4">
                <.icon name="hero-x-circle" class="text-red-500 w-8" />
                <p>{error_message(:invalid)}</p>
              </div>
          <% end %>
        </div>
      </.modal>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current_page, :scanner)
     |> assign(:modal_data, nil)
     |> assign(:given_list, [])}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("scan", data, socket) do
    case safely_extract_id_from_url(data) do
      {:ok, id} -> process_scan(id, socket)
      {:error, _} -> {:noreply, assign(socket, :modal_data, :invalid)}
    end
  end

  @impl true
  def handle_event("close-modal", _, socket) do
    {:noreply, socket |> assign(:modal_data, nil)}
  end

  defp process_scan(id, socket) do
    if id in socket.assigns.given_list do
      {:noreply, socket}
    else
      check_credential(id, socket)
    end
  end

  defp check_credential(id, socket) do
    if Accounts.credential_exists?(id) do
      handle_attendee_lookup(id, socket)
    else
      {:noreply, assign(socket, :modal_data, :not_found)}
    end
  end

  defp handle_attendee_lookup(id, socket) do
    case Accounts.get_attendee_from_credential(id, [:user]) do
      nil ->
        {:noreply, assign(socket, :modal_data, :not_linked)}

      attendee ->
        user_id = attendee.user && attendee.user.id

        case Tickets.get_user_ticket(user_id) do
          nil ->
            {:noreply, assign(socket, :modal_data, :no_ticket)}

          ticket ->
            ticket = Repo.preload(ticket, ticket_type: :perks)

            {:noreply,
             socket
             |> assign(:modal_data, {:ticket, ticket})
             |> assign(:given_list, [id | socket.assigns.given_list])}
        end
    end
  end

  defp error_message(:no_ticket), do: gettext("Attendee does not have a ticket")

  defp error_message(:not_found),
    do: gettext("This credential is not registered")

  defp error_message(:not_linked),
    do: gettext("This credential is not linked to any attendee")

  defp error_message(:invalid), do: gettext("Invalid credential")
end
