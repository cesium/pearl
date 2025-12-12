defmodule PearlWeb.Checkout.PaymentLive do
  use PearlWeb, :checkout_view

  def mount(_params, _, socket) do
    {:ok, socket}
  end
end
