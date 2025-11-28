defmodule PearlWeb.Backoffice.TicketsLive.TicketTypesLive.FormComponent do
  use PearlWeb, :live_component

  alias Pearl.TicketTypes

  import PearlWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          {gettext("Ticket types for the event.")}
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="ticket-type-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.field field={@form[:name]} type="text" label="Name" required />
        <.field field={@form[:description]} type="textarea" label="Description" />
        <.field field={@form[:price]} type="number" label="Price (€)" step="0.01" required />
        <:actions>
          <.button phx-disable-with="Saving...">Save Ticket Type</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{ticket_type: ticket_type} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(TicketTypes.change_ticket_type(ticket_type))
     end)}
  end

  @impl true
  def handle_event("validate", %{"ticket_type" => ticket_type_params}, socket) do
    changeset = TicketTypes.change_ticket_type(socket.assigns.ticket_type, ticket_type_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"ticket_type" => ticket_type_params}, socket) do
    save_ticket_type(socket, socket.assigns.action, ticket_type_params)
  end

  defp save_ticket_type(socket, :ticket_types_edit, ticket_type_params) do
    case TicketTypes.update_ticket_type(socket.assigns.ticket_type, ticket_type_params) do
      {:ok, _ticket_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ticket type updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_ticket_type(socket, :ticket_types_new, ticket_type_params) do
    case TicketTypes.create_ticket_type(
           ticket_type_params
           |> Map.put("priority", TicketTypes.get_next_ticket_type_priority())
           |> Map.put("active", true)
         ) do
      {:ok, _ticket_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ticket type created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
