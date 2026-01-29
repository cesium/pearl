defmodule PearlWeb.ConfirmationPendingLive do
  use PearlWeb, :checkout_view

  alias Pearl.Accounts

  import PearlWeb.Components.Button

  @delay_between_emails 30

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-lg py-12 text-primary">
      <div class="w-full flex items-center justify-center">
        <span class="">
          <.icon name="hero-envelope" class="w-10 h-10 sm:w-12 sm:h-12 text-primary" />
        </span>
      </div>
      <h1 class="px-4 uppercase text-3xl text-center mt-8 sm:mt-10 text-primary">
        {gettext("We need to verify your email address!")}
      </h1>
      <p class="text-center mt-6 px-4 text-dark-muted!">
        {gettext("We have sent an email to")}
        <span class="font-bold text-primary">{@current_user.email}</span>
        {gettext("containing instructions on how to verify your account.")}
      </p>
      <p class="text-center mt-4 px-4 text-dark-muted!">
        {gettext("If you don't see it, you may need to check your spam folder.")}
      </p>
      <p class="text-center mt-4 px-4 text-dark-muted!">
        {gettext("Still can't find it?")}
      </p>
      <div class="px-4 sm:px-24 text-center text-2xl sm:text-4xl mt-12">
        <.action_button
          title={gettext("Re-send Verification Email")}
          phx-click="resend"
          class="h-14! rounded-none border-dark-muted/30!"
          title_class="text-lg text-primary !normal-case"
        />
      </div>
      <p class="text-sm sm:text-md text-center mt-8 opacity-80 px-4">
        {gettext("Need help? Contact us at geral@eneiconf.pt.")}
      </p>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if is_nil(socket.assigns.current_user.confirmed_at) do
      {:ok, socket |> assign(:last_sent, nil)}
    else
      {:ok, socket |> push_navigate(to: ~p"/checkout/choose_ticket")}
    end
  end

  @impl true
  def handle_event("resend", _params, socket) do
    # To avoid sending many emails if a user decides to smash the resend button,
    # we only allow emails to be sent once every 30 seconds
    if throttle_socket?(socket) do
      {:noreply, socket}
    else
      Accounts.deliver_user_confirmation_instructions(
        socket.assigns.current_user,
        &url(~p"/users/confirm/#{&1}")
      )

      {:noreply,
       socket
       |> put_flash(:info, "The email has been sent to your inbox")
       |> assign(:last_sent, DateTime.utc_now())}
    end
  end

  defp throttle_socket?(socket) do
    not is_nil(socket.assigns.last_sent) and
      DateTime.diff(DateTime.utc_now(), socket.assigns.last_sent) < @delay_between_emails
  end
end
