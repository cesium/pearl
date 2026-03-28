defmodule PearlWeb.UserForgotPasswordLive do
  use PearlWeb, :auth_view

  alias Pearl.Accounts
  alias PearlWeb.Components.Button

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center min-h-screen px-4 py-8">
      <div class="w-full max-w-[1000px] relative">
        <div class="absolute left-1/2 top-0 -translate-x-1/2 -translate-y-full z-10 -mb-2.5">
          <img src="/images/braga_door.svg" alt="" class="w-16 h-auto" />
        </div>

        <div class="bg-white rounded-4xl px-8 sm:px-12 md:px-16 py-10 md:py-14 shadow-lg min-h-[420px] flex flex-col">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-8 md:gap-12 grow">
            <div>
              <h1 class="text-3xl md:text-4xl font-semibold text-black leading-tight mb-6 md:mb-8 wrap-break-word">
                {gettext("Recuperar palavra-passe")}
              </h1>

              <p class="text-sm md:text-base text-black/60 leading-relaxed">
                {gettext("Enviaremos um link de recuperação para o teu email")}
              </p>
            </div>

            <div class="flex flex-col h-full">
              <.simple_form
                for={@form}
                id="reset_password_form"
                phx-submit="send_email"
                class="flex flex-col h-full"
                wrapper_class="flex flex-col justify-between h-full"
              >
                <div>
                  <.input
                    field={@form[:email]}
                    type="email"
                    placeholder={gettext("E-mail")}
                    required
                  />
                </div>

                <div class="flex justify-end pt-8">
                  <Button.primary_button
                    title={gettext("continuar")}
                    icon="hero-arrow-right"
                    type="submit"
                  />
                </div>
              </.simple_form>
            </div>
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
      gettext(
        "Se o teu email estiver no nosso sistema, receberás instruções para redefinir a tua palavra-passe em breve."
      )

    {:noreply,
     socket
     |> put_flash(:success, info)
     |> redirect(to: ~p"/")}
  end
end
