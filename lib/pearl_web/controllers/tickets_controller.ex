defmodule PearlWeb.TicketsController do
  use PearlWeb, :controller

  alias Pearl.Tickets

  def init(conn, %{"ticket_type_id" => ticket_type_id}) do
    conn
    |> put_session(:ticket_type_id, ticket_type_id)
    |> redirect(to: "/checkout/choose_ticket")
  end

  def tickets_count(conn, %{"pearl_api_key" => pearl_api_key} = _params) do
    if pearl_api_key == Application.fetch_env!(:pearl, Pearl.Billing)[:pearl_api_key] do
      conn
      |> json(%{
        paid: Tickets.count_paid_tickets(),
        not_paid: Tickets.count_pending_tickets()
      })
    else
      conn
      |> send_resp(403, "invalid api key")
    end
  end
end
