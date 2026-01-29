defmodule PearlWeb.Checkout.PaymentLive do
  use PearlWeb, :checkout_view

  alias Ecto.Changeset
  alias Pearl.Tickets
  import PearlWeb.Components.Button

  @impl true
  def mount(_params, _, socket) do
    user_ticket = Tickets.get_user_ticket(socket.assigns.current_user.id)

    {
      :ok,
      socket
      |> assign(:ticket, user_ticket)
      |> assign(:ticket_type, user_ticket.ticket_type)
      # |> assign(:checkout_information, Billing.get_checkout_information(user.id))
      # |> assign(:payment_status, payment.payment_status)
      |> assign(:include_invoice_info, false)
      |> assign(:iva_number, "")
      |> assign(:payment_method, "mb_way")
      |> assign(:mb_way_phone, "")
      # |> assign_payment_form(payment_changeset(%{mb_way_phone: "", iva_number: ""}, false))
    }
  end

  @impl true
  def handle_event("toggle-invoice-info", _params, socket) do
    include_invoice_info = !socket.assigns.include_invoice_info

    # changeset = payment_changeset(%{mb_way_phone: socket.assigns.mb_way_phone, iva_number})
  end

  @impl true
  def handle_event("validate-payment", %{"payment" => payment_params}, socket) do
    phone = Map.get(payment_params, "mb_way_phone", "")
    iva_number = Map.get(payment_params, "iva_number", "")

    # changeset =
    #  payment_changeset(
    #    %{mb_way_phone: phone, iva_number: iva_number},
    #    socket.assigns.include_invoice_info
    #  )
    #  |> Map.put(:action, :validate)
    {
      :noreply,
      socket
      |> assign(:mb_way_phone, phone)
      |> assign(:iva_number, iva_number)
      # |> assign_payment_form(changeset)
    }
  end

  @impl true
  def handle_event("submit-payment", %{"payment" => payment_params}, socket) do
    phone = Map.get(payment_params, "mb_way_phone", "")
    iva_number = Map.get(payment_params, "iva_number", "")

    # changeset =
    #  payment_changeset(
    #    %{mb_way_phone: phone, iva_number: iva_number},
    #    socket.assigns.include_invoice_info
    #  )
    #  |> Map.put(:action, :validate)

    # if changeset.valid? do
    order_data = %{
      "phone_number" => phone,
      "tax_id" => if(socket.assigns.include_invoice_info, do: iva_number, else: "")
    }

    case Billing.start_payment(:mbway, socket.assigns.team.id, order_data) do
      {:ok, {:ok, payment}} ->
        {:noreply, push_navigate(socket, to: ~p"/app/payment/#{payment.order_id}")}

      {:error, _reason} ->
        {
          :noreply,
          socket
          |> put_flash(:error, "Failed to start payment. Please try again later.")
          # |> assign_payment_form(changeset)
        }
    end

    # else
    #  {:noreply, assign_payment_form(socket, changeset)}
    # end
  end

  defp assign_payment_form(socket, %Changeset{} = changeset) do
    form = to_form(changeset, as: :payment)

    socket
    |> assign(:payment_form, form)
    |> assign(:payment_changeset, changeset)
  end
end
