defmodule PearlWeb.Backoffice.ScannerLive.TicketsLive.Index do
  use PearlWeb, :backoffice_view

  alias Pearl.{Accounts, Activities, Tickets}

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
            <% {:ticket, %{ticket: ticket, user: user, attendee: _attendee}} -> %>
              <div class="flex flex-col gap-4">
                <%= if ticket do %>
                  <div class="flex items-center gap-4">
                    <.icon name="hero-check-circle" class="text-green-500 w-8" />
                    <div>
                      <p class="font-semibold">{ticket.ticket_type.name}</p>
                      <p class="text-sm text-muted">
                        {gettext("Status: %{status}",
                          status: if(ticket.paid, do: gettext("Paid"), else: gettext("Pending"))
                        )}
                      </p>
                    </div>
                  </div>
                <% end %>

                <div class="pt-2">
                  <p class="font-semibold">{gettext("Attendee")}</p>
                  <p class="text-sm">
                    <strong>{user.name}</strong>
                    &middot; <a class="underline" href={"mailto:" <> user.email}>{user.email}</a>
                  </p>
                </div>

                <%= if ticket && ticket.ticket_type.perks not in [nil, []] do %>
                  <div>
                    <p class="font-semibold">{gettext("Perks")}</p>
                    <ul class="list-disc ml-6">
                      <%= for perk <- ticket.ticket_type.perks do %>
                        <li>{perk.name}</li>
                      <% end %>
                    </ul>
                  </div>
                <% end %>

                <%= if @activity_tickets not in [nil, []] do %>
                  <div>
                    <p class="font-semibold">{gettext("Activity Tickets")}</p>
                    <ul class="list-disc ml-6">
                      <%= for ticket_type <- @activity_tickets do %>
                        <li>{ticket_type.name}</li>
                      <% end %>
                    </ul>
                  </div>
                <% end %>

                <%= if ticket do %>
                  <div>
                    <p class="font-semibold">{gettext("Dietary")}</p>
                    <p class="text-sm">
                      <%= if ticket.diet && ticket.diet != "no_restrictions" do %>
                        {gettext("Diet: %{diet}", diet: ticket.diet)}
                      <% else %>
                        {gettext("No dietary restrictions")}
                      <% end %>
                    </p>
                    <p class="font-semibold">{gettext("Allergens")}</p>

                    <p class="text-sm">
                      <%= if ticket.allergens && ticket.allergens != "none" do %>
                        {gettext("Allergens: %{allergens}", allergens: ticket.allergens)}
                      <% else %>
                        {gettext("No allergens")}
                      <% end %>
                    </p>
                  </div>
                <% end %>
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
     |> assign(:modal_data, nil)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("scan", data, socket) do
    case safely_extract_id_from_url(data) do
      {:ok, id} -> check_credential(id, socket)
      {:error, _} -> {:noreply, assign(socket, :modal_data, :invalid)}
    end
  end

  @impl true
  def handle_event("close-modal", _, socket) do
    {:noreply, socket |> assign(:modal_data, nil)}
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
        user = attendee.user
        user_id = user && user.id

        if is_nil(user_id) do
          {:noreply, assign(socket, :modal_data, :not_linked)}
        else
          ticket = Tickets.get_user_ticket(user_id)

          activity_tickets =
            Activities.get_user_activity_tickets(user_id)
            |> Enum.map(& &1.ticket_type)

          if ticket == nil and activity_tickets == [] do
            {:noreply, assign(socket, :modal_data, :no_ticket)}
          else
            {:noreply,
             socket
             |> assign(
               :modal_data,
               {:ticket, %{ticket: ticket, user: user, attendee: attendee}}
             )
             |> assign(:activity_tickets, activity_tickets)}
          end
        end
    end
  end

  defp error_message(:no_ticket), do: gettext("Attendee does not have a ticket!")

  defp error_message(:not_found),
    do: gettext("This credential is not registered in the event's system! (404)")

  defp error_message(:not_linked),
    do: gettext("This credential is not linked to any attendee! (400)")

  defp error_message(:invalid), do: gettext("Not a valid credential! (400)")
end
