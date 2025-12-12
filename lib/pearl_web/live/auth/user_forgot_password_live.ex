defmodule PearlWeb.UserForgotPasswordLive do
  use PearlWeb, :auth_view

  alias Pearl.Accounts

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center min-h-screen px-4 py-8">
      <div class="w-full max-w-sm md:max-w-xl space-y-3 md:space-y-4">
        <div class="bg-white rounded-4xl px-8 sm:px-12 md:px-16 py-10 md:py-14 shadow-lg">
          <div class="mb-8 md:mb-10">
            <div class="flex items-center gap-2 mb-5 md:mb-7">
              <img
                src="/images/enei-logo.svg"
                alt="ENEI Logo"
                class="h-5 md:h-6 w-auto pb-1"
              />
              <span class="text-primary font-light text-lg md:text-2xl leading-none">conta</span>
            </div>

            <h1 class="text-3xl md:text-4xl font-semibold text-black leading-tight mb-2">
              Recuperar palavra-passe
            </h1>
            <p class="text-sm md:text-base text-black/40">
              Enviaremos um link de recuperação para o teu email
            </p>
          </div>

          <.simple_form
            for={@form}
            id="reset_password_form"
            phx-submit="send_email"
            class="space-y-5 md:space-y-6 mb-32 md:mb-60"
          >
            <div>
              <.input
                field={@form[:email]}
                type="email"
                placeholder="E-mail"
                required
              />
            </div>
          </.simple_form>
        </div>

        <div class="bg-white rounded-full pr-2 pl-8 py-2 shadow-lg">
          <div class="flex items-center justify-between">
            <div class="text-sm md:text-base text-black/40 shrink">
              Já tens conta?
              <.link href={~p"/users/log_in"} class="text-primary underline hover:no-underline ml-1">
                Entra aqui
              </.link>
            </div>

            <button
              type="submit"
              form="reset_password_form"
              class="flex items-center justify-center gap-2 px-4 md:px-6 py-3 md:py-4 bg-primary text-white rounded-full text-sm md:text-base font-medium hover:bg-primary/90 transition-colors whitespace-nowrap shrink-0 ml-auto cursor-pointer"
            >
              <.icon name="hero-arrow-right" class="w-3.5 h-3.5 md:w-4 md:h-4" />
              <span>enviar</span>
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
