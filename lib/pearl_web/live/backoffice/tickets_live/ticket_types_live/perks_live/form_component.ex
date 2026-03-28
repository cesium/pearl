defmodule PearlWeb.Backoffice.TicketsLive.TicketTypesLive.PerksLive.FormComponent do
  use PearlWeb, :live_component

  alias Pearl.{Perks, Tickets}

  import PearlWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          {gettext("Perks for the ticket types.")}
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="perks-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.field field={@form[:name]} type="text" label="Name" required />
        <.field field={@form[:description]} type="textarea" label="Description" />
        <.field field={@form[:icon]} type="text" label="Icon" />
        <.field field={@form[:color]} type="text" label="Color" />
        <:actions>
          <.backoffice_button phx-disable-with="Saving...">Save Perk</.backoffice_button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{perk: perk} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Perks.change_perk(perk))
     end)}
  end

  @impl true
  def handle_event("validate", %{"perk" => perk_params}, socket) do
    changeset = Perks.change_perk(socket.assigns.perk, perk_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"perk" => perk_params}, socket) do
    save_perk(socket, socket.assigns.action, perk_params)
  end

  defp save_perk(socket, :perks_edit, perk_params) do
    case Perks.update_perk(socket.assigns.perk, perk_params) do
      {:ok, _perk} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Benefício atualizado com sucesso."))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_perk(socket, :perks_new, perk_params) do
    case Perks.create_perk(
           perk_params
           |> Map.put("active", true)
           |> Map.put("priority", Tickets.get_next_perk_priority())
         ) do
      {:ok, _perk} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Benefício criado com sucesso."))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
