defmodule PearlWeb.UserTicket do
  @moduledoc """
  Plugs for handling user ticket restrictions.
  """
  use PearlWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Pearl.{Billing, Tickets}

  def require_ticket(conn, _opts) do
    user = conn.assigns[:current_user]

    if user do
      ticket = Tickets.get_user_ticket(user.id)

      if is_nil(ticket) do
        conn
        |> redirect(to: ~p"/tickets")
        |> halt()
      else
        conn
      end
    end
  end

  def require_paid_ticket(conn, _opts) do
    user = conn.assigns[:current_user]

    if user do
      ticket = Tickets.get_user_ticket(user.id)

      if is_nil(ticket),
        do:
          conn
          |> redirect(to: ~p"/tickets")
          |> halt()

      case Billing.get_payment_by_ticket(ticket.id) do
        nil ->
          conn
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

  def require_payment(conn, _opts) do
    user = conn.assigns[:current_user]

    if user do
      ticket = Tickets.get_user_ticket(user.id)

      if ticket do
        case Billing.get_payment_by_ticket(ticket.id) do
          nil ->
            conn
            |> put_flash(:error, "Ainda não começaste o processo de pagamento.")
            |> redirect(to: ~p"/checkout/payment")
            |> halt()

          _payment ->
            conn
        end
      else
        conn
        |> put_flash(:error, "Ainda não começaste o processo de pagamento.")
        |> redirect(to: ~p"/checkout/payment")
        |> halt()
      end
    else
      conn
    end
  end

  def redirect_if_user_has_payment(conn, _opts) do
    user = conn.assigns[:current_user]

    if is_nil(user) do
      conn
    else
      ticket = Tickets.get_user_ticket(user.id)
      handle_user_ticket_payment(conn, ticket)
    end
  end

  defp handle_user_ticket_payment(conn, nil), do: conn

  defp handle_user_ticket_payment(conn, ticket) do
    case Billing.get_payment_by_ticket(ticket.id) do
      nil -> conn
      payment -> handle_payment_redirect(conn, payment)
    end
  end

  defp handle_payment_redirect(conn, payment) do
    if payment.status == :completed do
      conn
      |> redirect(to: ~p"/app")
      |> halt()
    else
      conn
      |> redirect(to: ~p"/checkout/payment/#{payment.order_id}")
      |> halt()
    end
  end

  def redirect_if_user_is_staff(conn, _opts) do
    user = conn.assigns[:current_user]

    if user && user.type == :staff do
      conn
      |> put_flash(:error, "Como staff, não tens acesso aos bilhetes")
      |> redirect(to: ~p"/app")
      |> halt()
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
            |> redirect(to: ~p"/checkout/payment")
            |> halt()
          end
      end
    else
      conn
    end
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
              |> Phoenix.LiveView.redirect(to: ~p"/checkout/payment")

            {:halt, socket}
          end
      end
    else
      {:cont, socket}
    end
  end
end
