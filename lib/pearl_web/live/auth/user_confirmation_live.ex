defmodule PearlWeb.UserConfirmationLive do
  use PearlWeb, :checkout_view

  alias Pearl.Accounts

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div
      id="user-email-confirmed"
      phx-hook="Redirect"
      class="mx-auto max-w-lg py-12 flex flex-col items-center"
    >
      <div class="w-full flex items-center justify-center">
        <span class="ring-2 sm:ring-4 ring-primary rounded-full p-4 sm:p-6">
          <.icon name="hero-check" class="w-10 h-10 sm:w-16 sm:h-16 text-primary" />
        </span>
      </div>
      <h1 class="px-4 font-terminal uppercase text-3xl text-center text-primary mt-8 sm:mt-10">
        {gettext("Endereço de email verificado!")}
      </h1>
      <p class="text-center text-primary mt-6 px-4">
        {gettext("A tua conta foi ativada com sucesso.")}
      </p>
      <p class="text-center text-primary mt-4 px-4">
        {gettext("A redirecionar...")}
      </p>
      <.link
        navigate={~p"/app"}
        class="text-sm sm:text-md text-center mt-8 opacity-80 px-4 hover:underline text-primary"
      >
        {gettext("Não está a funcionar? Clica aqui.")}
      </.link>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"token" => token}, _url, socket) do
    confirm_account(token, socket)
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def confirm_account(token, socket) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Utilizador confirmado com sucesso.")
         |> push_event("redirect", %{url: ~p"/app", time: 1200})}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply,
             push_event(socket, "redirect", %{url: ~p"/checkout/choose_ticket", time: 1200})}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "O link the confirmação é inválido ou expirou.")
             |> push_event("redirect", %{url: ~p"/app", time: 1200})}
        end
    end
  end
end
