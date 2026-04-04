defmodule PearlWeb.Backoffice.TicketsLive.TicketTypesLive.FormComponent do
  use PearlWeb, :live_component

  alias Pearl.{Activities, Perks, TicketTypes}

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
        <.field field={@form[:price]} type="number" label="Price" required step="0.01" />
        <.field
          field={@form[:product_key]}
          type="text"
          label="Product Key (UUID)"
          required
          placeholder="e.g. 550e8400-e29b-41d4-a716-446655440000"
        />

        <.field
          field={@form[:type]}
          type="select"
          label="Type"
          required
          options={[
            {"Event", "event"},
            {"Activity", "activity"}
          ]}
        />

        <%= if @show_activity_selector do %>
          <.field
            field={@form[:activity_id]}
            type="select"
            label="Activity"
            required
            options={@activity_options}
            prompt="Select an activity"
          />
        <% end %>

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
    activities = Activities.list_activities()

    activity_options =
      Enum.map(activities, fn activity ->
        {activity.title, activity.id}
      end)

    selected_ids =
      case ticket_type.perks do
        %Ecto.Association.NotLoaded{} -> []
        perks when is_list(perks) -> Enum.map(perks, & &1.id)
        _ -> []
      end

    ticket_type_type = ticket_type.type || :event
    show_activity_selector = ticket_type_type == :activity

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:perks, perks)
     |> assign(:activity_options, activity_options)
     |> assign(:selected_perks_ids, selected_ids)
     |> assign(:show_activity_selector, show_activity_selector)
     |> assign_new(:form, fn ->
       # Ensure type has a default value for new records
       changeset = TicketTypes.change_ticket_type(ticket_type)

       changeset =
         if is_nil(ticket_type.type) do
           Ecto.Changeset.put_change(changeset, :type, :event)
         else
           changeset
         end

       to_form(changeset)
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

    show_activity_selector =
      case ticket_type_params do
        %{"type" => "activity"} -> true
        _ -> false
      end

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))
     |> assign(selected_perks_ids: selected_ids)
     |> assign(show_activity_selector: show_activity_selector)}
  end

  def handle_event("save", %{"ticket_type" => ticket_type_params}, socket) do
    save_ticket_type(socket, socket.assigns.action, ticket_type_params)
  end

  defp clean_ticket_type_params(params) do
    params
    |> maybe_clear_activity_id()
    |> clean_empty_strings()
  end

  defp maybe_clear_activity_id(%{"type" => "event"} = params) do
    Map.put(params, "activity_id", nil)
  end

  defp maybe_clear_activity_id(params), do: params

  defp clean_empty_strings(params) do
    Enum.reduce(params, %{}, fn {key, value}, acc ->
      case value do
        "" -> Map.put(acc, key, nil)
        val when is_list(val) -> Map.put(acc, key, val)
        _ -> Map.put(acc, key, value)
      end
    end)
  end

  defp save_ticket_type(socket, :ticket_types_edit, ticket_type_params) do
    perk_ids = Map.get(ticket_type_params, "perk_ids", []) |> Enum.reject(&(&1 == ""))

    ticket_type_params = clean_ticket_type_params(ticket_type_params)

    with {:ok, ticket_type} <-
           TicketTypes.update_ticket_type(socket.assigns.ticket_type, ticket_type_params),
         {:ok, _ticket_type} <- TicketTypes.upsert_ticket_type_perks(ticket_type, perk_ids) do
      {:noreply,
       socket
       |> put_flash(:success, gettext("Tipo de bilhete atualizado com sucesso."))
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset, action: :validate))
         |> put_flash(:error, "Failed to update ticket type. Please check the form for errors.")}
    end
  end

  defp save_ticket_type(socket, :ticket_types_new, ticket_type_params) do
    perk_ids = Map.get(ticket_type_params, "perk_ids", []) |> Enum.reject(&(&1 == ""))

    ticket_type_params =
      ticket_type_params
      |> clean_ticket_type_params()
      |> Map.put_new("type", "event")

    with {:ok, ticket_type} <-
           TicketTypes.create_ticket_type(
             ticket_type_params
             |> Map.put("priority", TicketTypes.get_next_ticket_type_priority())
             |> Map.put("active", true)
           ),
         {:ok, _ticket_type} <- TicketTypes.upsert_ticket_type_perks(ticket_type, perk_ids) do
      {:noreply,
       socket
       |> put_flash(:success, gettext("Tipo de bilhete criado com sucesso."))
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset, action: :validate))
         |> put_flash(:error, "Failed to create ticket type. Please check the form for errors.")}
    end
  end
end
