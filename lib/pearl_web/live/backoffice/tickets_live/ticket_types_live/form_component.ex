defmodule PearlWeb.Backoffice.TicketsLive.TicketTypesLive.FormComponent do
  use PearlWeb, :live_component

  alias Pearl.{Perks, TicketTypes}

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
        <.field field={@form[:price]} type="number" label="Price" required />
        <.field field={@form[:product_key]} type="text" label="Product Key" required />
        <div class="space-y-2">
          <label class="block text-sm font-semibold leading-6">
            Perks
          </label>
          <div class="space-y-2">
            <%= for perk <- @perks do %>
              <label class="flex items-center gap-2">
                <input
                  type="checkbox"
                  name="ticket_type[perk_ids][]"
                  value={perk.id}
                  checked={perk.id in @selected_perks_ids}
                  class="rounded border-dark/10 text-dark/90 focus:ring-0"
                />
                <span class="text-sm">{perk.name}</span>
              </label>
            <% end %>
          </div>
          <input type="hidden" name="ticket_type[perk_ids][]" value="" />
        </div>
        <:actions>
          <.backoffice_button phx-disable-with="Saving...">Save Ticket Type</.backoffice_button>
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
  def update(%{ticket_type: ticket_type} = assigns, socket) do
    perks = Perks.list_perks()

    selected_ids =
      case ticket_type.perks do
        %Ecto.Association.NotLoaded{} -> []
        perks when is_list(perks) -> Enum.map(perks, & &1.id)
        _ -> []
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:perks, perks)
     |> assign(:selected_perks_ids, selected_ids)
     |> assign_new(:form, fn ->
       to_form(TicketTypes.change_ticket_type(ticket_type))
     end)}
  end

  @impl true
  def handle_event("validate", %{"ticket_type" => ticket_type_params}, socket) do
    changeset = TicketTypes.change_ticket_type(socket.assigns.ticket_type, ticket_type_params)

    selected_ids =
      case ticket_type_params do
        %{"perk_ids" => ids} when is_list(ids) ->
          ids |> Enum.reject(&(&1 == "" or is_nil(&1)))

        _ ->
          []
      end

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))
     |> assign(selected_perks_ids: selected_ids)}
  end

  def handle_event("save", %{"ticket_type" => ticket_type_params}, socket) do
    save_ticket_type(socket, socket.assigns.action, ticket_type_params)
  end

  defp save_ticket_type(socket, :ticket_types_edit, ticket_type_params) do
    perk_ids = Map.get(ticket_type_params, "perk_ids", []) |> Enum.reject(&(&1 == ""))

    with {:ok, ticket_type} <-
           TicketTypes.update_ticket_type(socket.assigns.ticket_type, ticket_type_params),
         {:ok, _ticket_type} <- TicketTypes.upsert_ticket_type_perks(ticket_type, perk_ids) do
      {:noreply,
       socket
      |> put_flash(:info, gettext("Tipo de bilhete atualizado com sucesso."))
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_ticket_type(socket, :ticket_types_new, ticket_type_params) do
    perk_ids = Map.get(ticket_type_params, "perk_ids", []) |> Enum.reject(&(&1 == ""))

    with {:ok, ticket_type} <-
           TicketTypes.create_ticket_type(
             ticket_type_params
             |> Map.put("priority", TicketTypes.get_next_ticket_type_priority())
             |> Map.put("active", true)
           ),
         {:ok, _ticket_type} <- TicketTypes.upsert_ticket_type_perks(ticket_type, perk_ids) do
      {:noreply,
       socket
      |> put_flash(:info, gettext("Tipo de bilhete criado com sucesso."))
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
