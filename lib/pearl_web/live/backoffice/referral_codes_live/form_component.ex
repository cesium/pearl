defmodule PearlWeb.Backoffice.ReferralsLive.FormComponent do
  use PearlWeb, :live_component

  import PearlWeb.Components.Forms
  alias Pearl.Referrals

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <.header>
          {@title}
          <:subtitle>
            {gettext("Companies sponsor the event.")}
          </:subtitle>
        </.header>

        <.simple_form
          for={@form}
          id="referral-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
          autocomplete="off"
        >
        <div>
          <div class="grid grid-cols-2">
            <.field field={@form[:code]} type="text" label="Code" wrapper_class="pr-2" required />
          </div>
        </div>
          <:actions>
            <.backoffice_button phx-disable-with="Saving...">Save Referral</.backoffice_button>
          </:actions>
        </.simple_form>
      </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket}
  end

  @impl true
  def update(%{referral: referral} = assigns, socket) do
    {:ok,
    socket
    |> assign(assigns)
    |> assign(:referral, referral)
    |> assign_new(:form, fn ->
      to_form(Referrals.change_referral(referral))
    end)}
  end

  @impl true
  def handle_event("validate", %{"referral" => referral_params}, socket) do
    changeset = Referrals.change_referral(socket.assigns.referral, referral_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"referral" => referral_params}, socket) do
    save_referral(socket, socket.assigns.action, referral_params)
  end

  def save_referral(socket, :edit, referral_params) do
    case Referrals.update_referral(socket.assigns.referral, referral_params) do
      {:ok, _referral} ->
        {:noreply, socket
          |> put_flash(:info, "Referral updated succesfully")
          |> push_patch(to: socket.assigns.patch)
        }
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def save_referral(socket, :new, referral_params) do
    case Referrals.create_referral(referral_params) do
      {:ok, _referral} ->
        {:noreply, socket
          |> put_flash(:info, "Referral created succesfully")
          |> push_patch(to: socket.assigns.patch)
        }
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end


end
