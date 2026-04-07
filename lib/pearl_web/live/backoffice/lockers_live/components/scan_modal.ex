defmodule PearlWeb.Backoffice.LockersLive.Components.ScanModal do
  @moduledoc """
  Modal for the attendee credential scan modal.
  """

  use PearlWeb, :component

  import PearlWeb.Components.{Button, Modal}

  attr :modal, :atom, required: true

  def scan_modal(assigns) do
    ~H"""
    <.modal
      :if={@modal == :scan_attendee}
      id="credential-scan-modal"
      show
      body_class="bg-light dark:bg-dark p-8 sm:p-14 shadow-zinc-700/10 shadow-lg aspect_square rounded-2xl w-full max-w-lg mx-auto"
      on_cancel={JS.push("close-modal")}
    >
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
    """
  end
end
