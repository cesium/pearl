defmodule PearlWeb.UserSessionController do
  use PearlWeb, :controller

  alias Pearl.Accounts
  alias PearlWeb.UserAuth

  def new(conn, %{"user" => user_params}) do
    case Accounts.register_attendee_user(user_params) do
      {:ok, %{user: user, attendee: _}} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        conn
        |> UserAuth.log_in_user(user, user_params)
  |> put_flash(:success, gettext("Registo efetuado com sucesso."))
        |> redirect(to: ~p"/app")

      {:error, _, %Ecto.Changeset{} = _changeset, _} ->
        conn
  |> put_flash(:error, gettext("Não foi possível registar. Este email pode já estar registado."))
        |> redirect(to: ~p"/users/register")
    end
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    redirect_url = Map.get(params, "_redirect_url", ~p"/app/")
    notification_text = Map.get(params, "_notification_text", "Password updated successfully!")

    conn
    |> put_session(:user_return_to, redirect_url)
    |> create(params, notification_text)
  end

  def create(conn, params) do
    create(conn, params, nil)
  end

  defp create(
         conn,
         %{
           "user" => user_params
         } = params,
         info
       ) do
    %{"email" => email, "password" => password} = user_params

    action = Map.get(params, "action")
    action_id = Map.get(params, "action_id")
    return_to = Map.get(params, "return_to")

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> process_action(action, action_id, user, return_to, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, gettext("Email ou palavra-passe inválidos."))
      |> redirect(to: conn.request_path)
    end
  end

  def delete(conn, _params) do
    conn
    |> UserAuth.log_out_user()
  end

  defp process_action(conn, "enrol", id, user, return_to, _info) do
    attendee = Pearl.Accounts.get_user_attendee(user.id)

    case Pearl.Activities.enrol(attendee.id, id) do
      {:ok, _} ->
  put_flash(conn, :success, gettext("Inscrição efetuada com sucesso."))
        |> put_session(:user_return_to, return_to)

      {:error, _, _, _} ->
        put_flash(conn, :error, gettext("Não foi possível inscrever-se"))
    end
  end

  defp process_action(conn, _action, _id, _user, _return_to, nil), do: conn

  defp process_action(conn, _action, _id, _user, _return_to, info),
  do: put_flash(conn, :info, Gettext.gettext(PearlWeb.Gettext, info))
end
