defmodule PearlWeb.UserUpdateEmailConfirmation do
  @moduledoc """
  A live view where the new email is confirmed an updated, over the token passed in the URL.
  """
  use PearlWeb, :live_view

  alias Pearl.Accounts

  def mount(%{"token" => token}, _session, socket) do
    user = socket.assigns.current_user

    socket =
      case Accounts.update_user_email(user, token) do
        :ok ->
          put_flash(socket, :success, gettext("Email alterado com sucesso."))
        :error ->
          put_flash(socket, :error, gettext("O link de alteração de email é inválido ou expirou."))
      end

    redirect_path = get_redirect_path(user)

    {:ok,
     socket
     |> push_navigate(to: redirect_path)}
  end

  defp get_redirect_path(user) do
    case user.type do
      :attendee -> "/settings"
      :staff -> "/dashboard/profile_settings"
      :company -> "/dashboard/profile_settings"
    end
  end
end
