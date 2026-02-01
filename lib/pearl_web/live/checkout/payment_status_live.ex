defmodule PearlWeb.Checkout.PaymentStatusLive do
  use PearlWeb, :checkout_view

  alias Pearl.Billing

  @impl true
  def mount(%{"id" => order_id}, _session, socket) do
    if connected?(socket) do
      Billing.subscribe_to_payment_order_updates(order_id)
    end

    payment = Billing.get_payment_by_order_id!(order_id)
    {:ok, socket |> assign(payment: payment)}
  end

  @impl true
  def handle_info({:payment_order_updated, payment}, socket) do
    {:noreply,
     socket
     |> assign(payment: payment)
     |> put_flash(:info, "Payment confirmed successfully.")}
  end
end
