defmodule PearlWeb.UserConfirmationInstructionsLive do
  use PearlWeb, :live_view

  alias Pearl.Accounts

  import PearlWeb.Components.Button

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        No confirmation instructions received?
        <:subtitle>We'll send a new confirmation link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.backoffice_button phx-disable-with="Sending..." class="w-full">
            Resend confirmation instructions
          </.backoffice_button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/users/register"}>Register</.link>
        | <.link href={~p"/users/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      "Se o teu email estiver no nosso sistema e ainda não tiver sido confirmado, receberás um email com instruções em breve."

    {:noreply,
     socket
     |> put_flash(:info, Gettext.gettext(PearlWeb.Gettext, info))
     |> redirect(to: ~p"/")}
  end
end
