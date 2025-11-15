defmodule PearlWeb.App.CredentialLive.Index do
  use PearlWeb, :app_view

  alias Pearl.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current_page, :credential)
     |> assign(
       :credential,
       Accounts.get_credential_of_attendee!(socket.assigns.current_user.attendee)
     )}
  end
end
