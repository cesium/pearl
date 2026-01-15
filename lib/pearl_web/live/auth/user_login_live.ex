defmodule PearlWeb.UserLoginLive do
  use PearlWeb, :auth_view

  alias Pearl.Event
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
              <h1 class="text-3xl md:text-4xl font-semibold text-black leading-tight mb-6 md:mb-8">
                {gettext("Iniciar sessão")}
              </h1>

              <p class="text-sm md:text-base text-black/60 leading-relaxed">
                {gettext(
                  "Na tua conta do ENEI está a tua credencial, os teus jogos e os teus prémios. Inicia sessão para descobrires o mundo a tua espera."
                )}
              </p>
            </div>

            <div class="flex flex-col h-full">
              <.simple_form
                for={@form}
                id="login_form"
                action={
                  ~p"/users/log_in?action=#{@action || ""}&action_id=#{@action_id || ""}&return_to=#{@return_to || ""}"
                }
                phx-update="ignore"
                class="flex flex-col h-full"
                wrapper_class="flex flex-col justify-between h-full space-y-5 md:space-y-6"
              >
                <div class="space-y-5 md:space-y-6">
                  <div>
                    <.input
                      field={@form[:email]}
                      type="email"
                      placeholder={gettext("E-mail ou número de telefone")}
                      required
                    />
                  </div>

                  <div>
                    <.input
                      field={@form[:password]}
                      type="password"
                      placeholder={gettext("Palavra-passe")}
                      required
                    />
                  </div>

                  <div class="pt-2">
                    <.input
                      field={@form[:remember_me]}
                      type="checkbox"
                      label={gettext("Manter sessão iniciada")}
                      class="w-4 h-4 border-2 border-black/20 rounded text-primary focus:ring-primary focus:ring-offset-0 cursor-pointer"
                      wrapper_class="[&_label]:text-sm [&_label]:md:text-base [&_label]:text-black/60"
                    />
                  </div>
                </div>

                <div class="flex justify-end pt-8">
                  <Button.primary_button
                    title={gettext("continuar")}
                    icon="hero-arrow-right"
                    type="submit"
                  />

                  <Button.secondary_button
                    title={gettext("não consigo entrar")}
                    no_icon
                    phx-click={JS.navigate(~p"/users/reset_password")}
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
