defmodule PearlWeb.UserLoginLive do
  use PearlWeb, :auth_view

  alias Pearl.Event

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

            <h1 class="text-4xl md:text-4xl font-semibold text-black leading-tight">
              Iniciar sessão
            </h1>
          </div>

          <.simple_form
            for={@form}
            id="login_form"
            action={
              ~p"/users/log_in?action=#{@action || ""}&action_id=#{@action_id || ""}&return_to=#{@return_to || ""}"
            }
            phx-update="ignore"
            class="space-y-5 md:space-y-6 mb-32 md:mb-60"
          >
            <div>
              <.input
                field={@form[:email]}
                type="email"
                placeholder="E-mail ou número de telefone"
                required
              />
            </div>

            <div>
              <.input
                field={@form[:password]}
                type="password"
                placeholder="Palavra-passe"
                required
              />
            </div>
          </.simple_form>
        </div>

        <div class="bg-white rounded-full px-8 sm:px-12 md:px-16 py-2 md:py-2 shadow-lg">
          <div class="flex items-center justify-between gap-3 md:gap-4">
            <div class="text-sm md:text-base text-black/40 shrink">
              Não consegues entrar?
              <.link
                href={~p"/users/reset_password"}
                class="text-primary underline hover:no-underline ml-1"
              >
                Carrega aqui
              </.link>
            </div>

            <button
              type="submit"
              form="login_form"
              class="flex items-center justify-center gap-2 px-4 md:px-6 py-3 md:py-4 bg-primary text-white rounded-full text-sm md:text-base font-medium hover:bg-primary/90 transition-colors whitespace-nowrap shrink-0 ml-auto"
            >
              <.icon name="hero-arrow-right" class="w-3.5 h-3.5 md:w-4 md:h-4" />
              <span>continuar</span>
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok,
     assign(socket, form: form)
     |> assign(registrations_open: Event.registrations_open?())
     |> assign(:action_id, Map.get(params, "action_id"))
     |> assign(:action, Map.get(params, "action"))
     |> assign(:return_to, Map.get(params, "return_to")), temporary_assigns: [form: form]}
  end
end
