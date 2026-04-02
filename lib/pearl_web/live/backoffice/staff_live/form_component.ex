defmodule PearlWeb.Backoffice.StaffLive.FormComponent do
  use PearlWeb, :live_component

  import PearlWeb.Components.Forms
  alias Pearl.Accounts
  alias Pearl.Accounts.User
  alias Pearl.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <.simple_form
          for={@form}
          id="staff-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
          autocomplete="off"
        >
          <div class="flex flex-col md:flex-row w-full gap-4">
            <div class="w-full space-y-2">
              <.field field={@form[:name]} type="text" label="Name" required />
              <.field
                field={@form[:email]}
                type="email"
                label="Email"
                autocomplete="new-email"
                required
              />
              <.field
                field={@form[:password]}
                type="password"
                label="Password"
                required={@action == :new}
                autocomplete="new-password"
              />
              <.field field={@form[:handle]} type="text" label="Handle" required />
              <.inputs_for :let={u} field={@form[:staff]}>
                <.field field={u[:role_id]} type="select" label="Role" options={@roles} required />
              </.inputs_for>
            </div>
          </div>
          <:actions>
            <.backoffice_button phx-disable-with="Saving...">Save Staff</.backoffice_button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    user = user |> Repo.preload(:staff)
    user_changeset = Accounts.change_user_registration(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:user, user)
     |> assign(:form, to_form(user_changeset))}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      Accounts.change_user_registration(%User{}, user_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_staff(socket, socket.assigns.action, user_params)
  end

  defp save_staff(socket, :new, user_params) do
    case Accounts.register_staff_user(user_params) do
      {:ok, _staff} ->
        {:noreply,
         socket
         |> put_flash(:success, gettext("Staff criado com sucesso"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, _, %Ecto.Changeset{} = changeset, _} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Ocorreu um erro ao criar o staff."))
         |> assign(:form, to_form(changeset, action: :validate))}
    end
  end

  defp save_staff(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, _staff} ->
        {:noreply,
         socket
         |> put_flash(:success, gettext("Staff atualizado com sucesso."))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Ocorreu um erro ao atualizar o staff."))
         |> assign(:form, to_form(changeset))}
    end
  end
end
