defmodule PearlWeb.Backoffice.DiscountCodesLive.FormComponent do
  use PearlWeb, :live_component

  alias Pearl.DiscountCodes
  alias Pearl.TicketTypes

  import PearlWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          {gettext("Manage discount codes for tickets.")}
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="discount-code-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        autocomplete="off"
      >
        <.field
          field={@form[:code]}
          type="text"
          label="Code"
          required
        />

        <.field
          field={@form[:amount]}
          type="number"
          label="Discount (%)"
          required
        />

        <.field
          field={@form[:usage_limit]}
          type="number"
          label="Usage Limit"
          required
        />

        <.field
          field={@form[:active]}
          type="checkbox"
          label="Active"
        />

        <div class="space-y-2">
          <label class="block text-sm font-semibold leading-6">
            Ticket Types
          </label>
          <div class="space-y-2">
            <%= for ticket_type <- @ticket_types do %>
              <label class="flex items-center gap-2">
                <input
                  type="checkbox"
                  name="discount_code[ticket_type_ids][]"
                  value={ticket_type.id}
                  checked={ticket_type.id in @selected_ticket_type_ids}
                  class="rounded border-dark/10 text-dark/90 focus:ring-0"
                />
                <span class="text-sm">{ticket_type.name}</span>
              </label>
            <% end %>
          </div>
          <input type="hidden" name="discount_code[ticket_type_ids][]" value="" />
        </div>

        <:actions>
          <.backoffice_button phx-disable-with="Saving...">Save Discount Code</.backoffice_button>
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
  def update(%{discount_code: discount_code} = assigns, socket) do
    ticket_types = TicketTypes.list_ticket_types()

    selected_ids =
      case discount_code.ticket_types do
        %Ecto.Association.NotLoaded{} -> []
        ticket_types when is_list(ticket_types) -> Enum.map(ticket_types, & &1.id)
        _ -> []
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:ticket_types, ticket_types)
     |> assign(:selected_ticket_type_ids, selected_ids)
     |> assign_new(:form, fn ->
       to_form(DiscountCodes.change_discount_code(discount_code))
     end)}
  end

  @impl true
  def handle_event("validate", %{"discount_code" => discount_code_params}, socket) do
    changeset =
      DiscountCodes.change_discount_code(socket.assigns.discount_code, discount_code_params)

    selected_ids =
      case discount_code_params do
        %{"ticket_type_ids" => ids} when is_list(ids) ->
          ids |> Enum.reject(&(&1 == "" or is_nil(&1)))

        _ ->
          []
      end

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))
     |> assign(selected_ticket_type_ids: selected_ids)}
  end

  def handle_event("save", %{"discount_code" => discount_code_params}, socket) do
    save_discount_code(socket, socket.assigns.action, discount_code_params)
  end

  defp save_discount_code(socket, :edit, discount_code_params) do
    ticket_type_ids =
      Map.get(discount_code_params, "ticket_type_ids", []) |> Enum.reject(&(&1 == ""))

    with {:ok, discount_code} <-
           DiscountCodes.update_discount_code(socket.assigns.discount_code, discount_code_params),
         {:ok, _discount_code} <-
           DiscountCodes.upsert_discount_code_ticket_types(discount_code, ticket_type_ids) do
      {:noreply,
       socket
       |> put_flash(:success, gettext("Código de desconto atualizado com sucesso"))
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_discount_code(socket, :new, discount_code_params) do
    ticket_type_ids =
      Map.get(discount_code_params, "ticket_type_ids", []) |> Enum.reject(&(&1 == ""))

    with {:ok, discount_code} <- DiscountCodes.create_discount_code(discount_code_params),
         {:ok, _discount_code} <-
           DiscountCodes.upsert_discount_code_ticket_types(discount_code, ticket_type_ids) do
      {:noreply,
       socket
       |> put_flash(:success, gettext("Código de desconto criado com sucesso"))
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
