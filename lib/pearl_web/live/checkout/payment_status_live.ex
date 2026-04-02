defmodule PearlWeb.Checkout.PaymentStatusLive do
  use PearlWeb, :checkout_view

  alias Pearl.{Billing, TicketTypes}

  @impl true
  def mount(%{"id" => order_id}, _session, socket) do
    if connected?(socket) do
      Billing.subscribe_to_payment_order_updates(order_id)
    end

    payment = Billing.get_payment_by_order_id!(order_id)
    ticket_type = TicketTypes.get_ticket_type!(payment.ticket.ticket_type_id)

    {:ok,
     socket
     |> assign(payment: payment)
     |> assign(ticket_type: ticket_type)}
  end

  @impl true
  def handle_info({:payment_order_updated, payment}, socket) do
    {:noreply,
     socket
     |> assign(payment: payment)
     |> put_flash(:success, gettext("Pagamento confirmado com sucesso."))
     |> redirect(to: ~p"/app")}
  end
end
