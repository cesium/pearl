defmodule PearlWeb.Checkout.ActivityTicketLive do
  use PearlWeb, :checkout_view

  alias Ecto.Changeset
  alias Pearl.{Activities, Billing, TicketTypes}
  import PearlWeb.Components.Button

  def mount(_params, session, socket) do
    ticket_type_id = Map.get(session, "activity_ticket_type_id")

    case ticket_type_id && TicketTypes.get_ticket_type!(ticket_type_id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Bilhete não encontrado.")
         |> push_navigate(to: ~p"/tickets")}

      ticket_type ->
        {:ok,
         socket
         |> assign(:ticket_type, ticket_type)
         |> assign(:payment_method, "mb_way")
         |> assign(:include_invoice_info, false)
         |> assign(:mb_way_phone, "")
         |> assign(:iva_number, "")
         |> assign_payment_form(payment_changeset(%{mb_way_phone: "", iva_number: ""}, false))}
    end
  end

  def handle_event("toggle-invoice-info", _params, socket) do
    include_invoice_info = !socket.assigns.include_invoice_info

    changeset =
      payment_changeset(
        %{mb_way_phone: socket.assigns.mb_way_phone, iva_number: socket.assigns.iva_number},
        include_invoice_info
      )

    {:noreply,
     socket
     |> assign(:include_invoice_info, include_invoice_info)
     |> assign_payment_form(Map.put(changeset, :action, :validate))}
  end

  def handle_event("validate-payment", %{"payment" => payment_params}, socket) do
    phone = Map.get(payment_params, "mb_way_phone", "")
    iva_number = Map.get(payment_params, "iva_number", "")

    changeset =
      payment_changeset(
        %{mb_way_phone: phone, iva_number: iva_number},
        socket.assigns.include_invoice_info
      )
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:mb_way_phone, phone)
     |> assign(:iva_number, iva_number)
     |> assign_payment_form(changeset)}
  end

  def handle_event("submit-payment", %{"payment" => payment_params}, socket) do
    phone = Map.get(payment_params, "mb_way_phone", "")
    iva_number = Map.get(payment_params, "iva_number", "")

    changeset =
      payment_changeset(
        %{mb_way_phone: phone, iva_number: iva_number},
        socket.assigns.include_invoice_info
      )
      |> Map.put(:action, :validate)

    if changeset.valid? do
      process_payment_submission(socket, phone, iva_number, changeset)
    else
      {:noreply, assign_payment_form(socket, changeset)}
    end
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/tickets")}
  end

  defp process_payment_submission(socket, phone, iva_number, changeset) do
    user_id = socket.assigns.current_user.id
    ticket_type = socket.assigns.ticket_type

    case Activities.get_activity_ticket_by_user_and_type(user_id, ticket_type.id, paid: false) do
      nil ->
        create_and_pay_activity_ticket(socket, ticket_type, user_id, phone, iva_number, changeset)

      activity_ticket ->
        handle_existing_unpaid_ticket(socket, activity_ticket, phone, iva_number, changeset)
    end
  end

  defp create_and_pay_activity_ticket(socket, ticket_type, user_id, phone, iva_number, changeset) do
    case Activities.create_activity_ticket(%{
           user_id: user_id,
           ticket_type_id: ticket_type.id,
           paid: false
         }) do
      {:ok, activity_ticket} ->
        start_payment_and_navigate(socket, activity_ticket, phone, iva_number, changeset, true)

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Não foi possível criar o bilhete.")
         |> assign_payment_form(changeset)}
    end
  end

  defp handle_existing_unpaid_ticket(socket, activity_ticket, phone, iva_number, changeset) do
    case Billing.get_payment_by_activity_ticket(activity_ticket.id) do
      %{} = payment ->
        {:noreply, push_navigate(socket, to: ~p"/checkout/activity/payment/#{payment.order_id}")}

      nil ->
        start_payment_and_navigate(socket, activity_ticket, phone, iva_number, changeset, false)
    end
  end

  defp start_payment_and_navigate(
         socket,
         activity_ticket,
         phone,
         iva_number,
         changeset,
         delete_on_error
       ) do
    order_data = %{
      "phone_number" => phone,
      "tax_id" => if(socket.assigns.include_invoice_info, do: iva_number, else: "")
    }

    case Billing.start_payment(:mbway, :activity, activity_ticket.id, order_data) do
      {:ok, {:ok, payment}} ->
        {:noreply, push_navigate(socket, to: ~p"/checkout/activity/payment/#{payment.order_id}")}

      {:error, _reason} ->
        if delete_on_error, do: Activities.delete_activity_ticket(activity_ticket)

        {:noreply,
         socket
         |> put_flash(
           :error,
           "Falha ao iniciar o pagamento. Por favor, tenta novamente."
         )
         |> assign_payment_form(changeset)}
    end
  end

  defp assign_payment_form(socket, %Changeset{} = changeset) do
    socket
    |> assign(:payment_form, to_form(changeset, as: :payment))
    |> assign(:payment_changeset, changeset)
  end

  defp payment_changeset(attrs, include_invoice_info) do
    types = %{mb_way_phone: :string, iva_number: :string}

    {%{}, types}
    |> Changeset.cast(attrs, Map.keys(types))
    |> Changeset.validate_required([:mb_way_phone])
    |> maybe_validate_nif(include_invoice_info)
  end

  defp maybe_validate_nif(changeset, true) do
    changeset
    |> Changeset.validate_required([:iva_number])
  end

  defp maybe_validate_nif(changeset, false), do: changeset
end
