defmodule PearlWeb.Backoffice.AttendeeLive.CredentialLive.FormComponent do
  use PearlWeb, :live_component

  alias Pearl.Accounts
  import PearlWeb.Components.{Button, Modal}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title="Credential"
        subtitle={gettext("Credential link settings for %{name}.", name: assigns.attendee.user.name)}
      >
        <div class="mt-5">
          <div :if={@has_credential}>
            <p>
              This user has a credential with the id
              <span class="font-semibold">#{@credential.id}</span>
              linked to his account
            </p>

            <div class="my-6 mx-auto w-fit scale-100 p-2 bg-light-muted rounded-xl select-none">
              {draw_qr_code(@credential) |> raw}
              <p class="text-center text-xs text-primary font-semibold py-1">
                {@attendee.user.name}
              </p>
            </div>
          </div>
          <div :if={!@has_credential} class="flex items-center justify-center gap-2">
            <.icon name="hero-exclamation-circle" class="text-warning-500" />
            <p>This user has no credentials linked to his account</p>
          </div>

          <.backoffice_button phx-click="confirm-modal" phx-target={@myself} class="w-full mt-4">
            {gettext("Link New Credential")}
          </.backoffice_button>
        </div>
      </.page>

      <.modal
        :if={@live_action in [:confirm_relink]}
        id="credential-confirm-modal"
        show
        on_cancel={JS.patch(~p"/dashboard/attendees/#{assigns.attendee.id}")}
      >
        <div class="mb-8 space-y-2">
          <h2 class="text-xl font-regular">
            {gettext("Are you sure you want to link a new credential?")}
          </h2>
          <h2 class="flex items-center justify-center gap-2 w-fit text-xl">
            <.icon name="hero-exclamation-triangle" class="text-danger-800" />
            {gettext("This will overwrite any linked credentials!")}
          </h2>
        </div>
        <div class="flex flex-row gap-x-4">
          <.backoffice_button phx-click="confirm" phx-target={@myself} class="w-full">
            {gettext("Confirm")}
          </.backoffice_button>

          <.backoffice_button
            phx-click="cancel"
            phx-value="Remove"
            phx-target={@myself}
            class="w-full"
          >
            {gettext("Cancel")}
          </.backoffice_button>
        </div>
      </.modal>

      <.modal
        :if={@live_action in [:relink]}
        id="credential-relink-modal"
        show
        on_cancel={JS.patch(~p"/dashboard/attendees/#{assigns.attendee.id}")}
      >
        <div
          id="qr-scanner"
          phx-hook="QrScanner"
          phx-target={@myself}
          data-target={@myself}
          data-ask_perm="permission-button"
          data-open_on_mount
          data-on_start="document.getElementById('scan-info').style.display = 'none'"
          data-on_success="scan"
          class="relative"
        >
        </div>

        <div id="scan-info" class="flex flex-col items-center gap-8 text-center py-8">
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
      </.modal>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:live_action, :default)}
  end

  @impl true
  def update(assigns, socket) do
    has_credential = Accounts.attendee_has_credential?(assigns.attendee.id)

    credential =
      if has_credential do
        Accounts.get_credential_of_attendee(assigns.attendee)
      else
        nil
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:live_action, :default)
     |> assign(:has_credential, has_credential)
     |> assign(:credential, credential)}
  end

  @impl true
  def handle_event("confirm-modal", _params, socket) do
    {:noreply, assign(socket, live_action: :confirm_relink)}
  end

  def handle_event("confirm", _params, socket) do
    {:noreply, assign(socket, live_action: :relink)}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, live_action: :default)}
  end

  def handle_event("scan", data, socket) do
    case safely_extract_id_from_url(data) do
      {:ok, id} ->
        if Accounts.credential_exists?(id) do
          if Accounts.credential_linked?(id) do
            {:noreply,
             socket
             |> put_flash(
               :error,
               "This credential is already linked to an attendee! (400)"
             )
             |> push_patch(to: ~p"/dashboard/attendees/#{socket.assigns.attendee.id}")}
          else
            Accounts.relink_credential(id, socket.assigns.attendee.id)

            {:noreply,
             socket
             |> put_flash(:info, "New credential linked to the user")
             |> push_patch(to: ~p"/dashboard/attendees/#{socket.assigns.attendee.id}")}
          end
        else
          {:noreply,
           socket
           |> put_flash(:error, "This credential is not registered in the event's system! (404)")
           |> push_patch(to: ~p"/dashboard/attendees/#{socket.assigns.attendee.id}")}
        end

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Not a vlaid credential! (400)")
         |> push_patch(to: ~p"/dashboard/attendees/#{socket.assigns.attendee.id}")}
    end
  end
end
