defmodule PearlWeb.UserTicket do
  @moduledoc """
  Plugs for handling user ticket restrictions.
  """
  use PearlWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Pearl.{Billing, Tickets}

  def require_paid_ticket(conn, _opts) do
    user = conn.assigns[:current_user]

    if user do
      ticket = Tickets.get_user_ticket(user.id)

      if is_nil(ticket),
        do:
          conn
          |> put_flash(:error, "Ainda não tens um bilhete!")
          |> redirect(to: ~p"/tickets")
          |> halt()

      case Billing.get_payment_by_ticket(ticket.id) do
        nil ->
          conn
          |> put_flash(:error, "Por favor, complete o pagamento do teu bilhete.")
          |> redirect(to: ~p"/checkout/payment")
          |> halt()

        payment ->
          if payment.status == :completed do
            conn
          else
            conn
            |> put_flash(:error, "Ainda não efetuaste o pagamento.")
            |> redirect(to: ~p"/checkout/payment/#{payment.order_id}")
            |> halt()
          end
      end
    end

    conn
  end

  def require_payment_started(conn, _opts) do
    user = conn.assigns[:current_user]

    if user do
      ticket = Tickets.get_user_ticket(user.id)

      case Billing.get_payment_by_ticket(ticket.id) do
        nil ->
          conn
          |> put_flash(:error, "Ainda não comecaste o processo de pagamento.")
          |> redirect(to: ~p"/checkout/payment")
          |> halt()

        _payment ->
          conn
      end
    end

    conn
  end

  def redirect_if_user_has_payment(conn, _opts) do
    user = conn.assigns[:current_user]

    if user do
      ticket = Tickets.get_user_ticket(user.id)

      case Billing.get_payment_by_ticket(ticket.id) do
        nil ->
          conn

        _payment ->
          conn
          |> put_flash(:error, "Já tens um pagamento completo ou a decorrer")
          |> redirect(to: ~p"/")
          |> halt()
      end
    end

    conn
  end

  def redirect_if_user_has_paid_ticket(conn, _opts) do
    if conn.assigns[:current_user] do
      case Tickets.get_user_ticket(conn.assigns.current_user.id) do
        nil ->
          conn

        ticket ->
          if ticket.paid do
            conn
            |> put_flash(:error, "Já tens um bilhete.")
            |> redirect(to: ~p"/checkout/payment")
            |> halt()
          else
            conn
          end
      end
    else
      conn
    end
  end

  def redirect_if_user_has_unpaid_ticket(conn, _opts) do
    if conn.assigns[:current_user] do
      case Tickets.get_user_ticket(conn.assigns.current_user.id) do
        nil ->
          conn

        ticket ->
          if ticket.paid do
            conn
          else
            conn
            |> put_flash(
              :error,
              "Tens um bilhete que ainda não foi pago. Por favor complete o pagamento."
            )
            |> redirect(to: ~p"/checkout/payment")
            |> halt()
          end
      end
    else
      conn
    end
  end

  def on_mount(:redirect_if_user_has_paid_ticket, _params, _session, socket) do
    if socket.assigns[:current_user] do
      case Tickets.get_user_ticket(socket.assigns.current_user.id) do
        nil ->
          {:cont, socket}

        ticket ->
          if ticket.paid do
            socket =
              socket
              |> Phoenix.LiveView.put_flash(:error, "Já tens um bilhete.")
              |> Phoenix.LiveView.redirect(to: ~p"/app")

            {:halt, socket}
          else
            {:cont, socket}
          end
      end
    else
      {:cont, socket}
    end
  end

  def on_mount(:redirect_if_user_has_unpaid_ticket, _params, _session, socket) do
    if socket.assigns[:current_user] do
      case Tickets.get_user_ticket(socket.assigns.current_user.id) do
        nil ->
          {:cont, socket}

        ticket ->
          if ticket.paid do
            {:cont, socket}
          else
            socket =
              socket
              |> Phoenix.LiveView.put_flash(
                :error,
                "Tens um bilhete que ainda não foi pago. Por favor complete o pagamento."
              )
              |> Phoenix.LiveView.redirect(to: ~p"/checkout/payment")

            {:halt, socket}
          end
      end
    else
      {:cont, socket}
    end
  end
end
