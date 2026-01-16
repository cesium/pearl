defmodule PearlWeb.UserTicket do
  @moduledoc """
  Plugs for handling user ticket restrictions.
  """
  use PearlWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Pearl.Tickets

  def redirect_if_user_has_paid_ticket(conn, _opts) do
    if conn.assigns[:current_user] do
      case Tickets.get_user_ticket(conn.assigns.current_user.id) do
        nil ->
          conn

        ticket ->
          if not ticket.paid do
            conn
          else
            conn
            |> put_flash(:error, "You already have a ticket.")
            |> redirect(to: ~p"/checkout/payment")
            |> halt()
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
            |> put_flash(:error, "You have an unpaid ticket. Please complete your payment.")
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
          if not ticket.paid do
            {:cont, socket}
          else
            socket =
              socket
              |> Phoenix.LiveView.put_flash(:error, "You already have a ticket.")
              |> Phoenix.LiveView.redirect(to: ~p"/app")

            {:halt, socket}
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
              |> Phoenix.LiveView.put_flash(:error, "You have an unpaid ticket. Please complete your payment.")
              |> Phoenix.LiveView.redirect(to: ~p"/checkout/payment")

            {:halt, socket}
          end
      end
    else
      {:cont, socket}
    end
  end
end
