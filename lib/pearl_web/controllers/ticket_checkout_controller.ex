defmodule PearlWeb.TicketCheckoutController do
  use PearlWeb, :controller

  def init(conn, %{"ticket_type_id" => ticket_type_id}) do
    conn
    |> put_session(:ticket_type_id, ticket_type_id)
    |> redirect(to: "/checkout/precautions")
  end
end
