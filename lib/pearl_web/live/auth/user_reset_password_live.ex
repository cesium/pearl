defmodule PearlWeb.UserResetPasswordLive do
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
              <h1 class="text-3xl md:text-4xl font-semibold text-black leading-tight mb-6 md:mb-8">
                {gettext("Redefinir palavra-passe")}
              </h1>

              <p class="text-sm md:text-base text-black/60 leading-relaxed">
                {gettext("Seleciona uma nova palavra-passe aqui.")}
              </p>
            </div>

            <div>
              <.simple_form
                for={@form}
                id="reset_password_form"
                phx-submit="reset_password"
                phx-change="validate"
                class="space-y-5 md:space-y-6"
              >
                <div>
                  <.input
                    field={@form[:password]}
                    type="password"
                    placeholder={gettext("Nova palavra-passe")}
                    required
                  />
                </div>

                <div>
                  <.input
                    field={@form[:password_confirmation]}
                    type="password"
                    placeholder={gettext("Confirmar palavra-passe")}
                    required
                  />
                </div>

                <div class="flex justify-end mt-20 pt-8">
                  <Button.primary_button
                    title={gettext("continuar")}
                    icon="hero-arrow-right"
                    type="submit"
                    disabled={@form.errors != []}
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
    socket = assign_user_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{user: user} ->
          Accounts.change_user_password(user)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Palavra-passe redefinida com sucesso."))
         |> redirect(to: ~p"/users/log_in")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(
        :error,
        gettext("O link de redefinição de palavra-passe é inválido ou expirou.")
      )
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
