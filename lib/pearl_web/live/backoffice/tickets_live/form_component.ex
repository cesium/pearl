defmodule PearlWeb.Backoffice.TicketsLive.FormComponent do
  use PearlWeb, :live_component

  alias Pearl.Tickets
  alias Pearl.TicketTypes

  import PearlWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          {gettext("Tickets of the users.")}
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="ticket-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        autocomplete="off"
      >
        <div>
          <div class="grid grid-cols-1 justify-center">
            <.field
              field={@form[:ticket_type_id]}
              type="select"
              options={ticket_type_options(@ticket_types)}
              label="Ticket Type"
              wrapper_class="pr-2"
              required
            />
            <.field
              field={@form[:paid]}
              type="checkbox"
              label="Paid"
              wrapper_class=""
            />
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Ticket</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{ticket: ticket} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:ticket, ticket)
     |> assign(:ticket_types, TicketTypes.list_ticket_types())
     |> assign_new(:form, fn ->
       to_form(Tickets.change_ticket(ticket))
     end)}
  end

  @impl true
  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    changeset = Tickets.change_ticket(socket.assigns.ticket, ticket_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"ticket" => ticket_params}, socket) do
    save_ticket(socket, ticket_params)
  end

  defp save_ticket(socket, ticket_params) do
    case Tickets.update_ticket(socket.assigns.ticket, ticket_params) do
      {:ok, _ticket} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ticket updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp ticket_type_options(ticket_types) do
    Enum.map(ticket_types, &{&1.name, &1.id})
  end
end
