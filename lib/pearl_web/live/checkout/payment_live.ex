defmodule PearlWeb.Checkout.PaymentLive do
  use PearlWeb, :checkout_view

  alias Ecto.Changeset
  alias Pearl.{Billing, Tickets}
  import PearlWeb.Components.Button

  @impl true
  def mount(_params, _, socket) do
    user_ticket = Tickets.get_user_ticket(socket.assigns.current_user.id)

    case user_ticket do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, gettext("Nenhum bilhete encontrado."))
         |> push_navigate(to: ~p"/checkout/choose_ticket")}

      ticket ->
        {
          :ok,
          socket
          |> assign(:ticket, ticket)
          |> assign(:ticket_type, ticket.ticket_type)
          |> assign(:phone, socket.assigns.current_user.phone)
          |> assign(:checkout_information, Billing.get_checkout_information(ticket.ticket_type))
          |> assign(:payment_status, ticket.paid)
          |> assign(:include_invoice_info, false)
          |> assign(:iva_number, "")
          |> assign(:payment_method, "mb_way")
          |> assign(:mb_way_phone, "")
          |> assign_payment_form(payment_changeset(%{mb_way_phone: "", iva_number: ""}, false))
        }
    end
  end

  @impl true
  def handle_event("toggle-invoice-info", _params, socket) do
    include_invoice_info = !socket.assigns.include_invoice_info

    changeset =
      payment_changeset(
        %{mb_way_phone: socket.assigns.mb_way_phone, iva_number: socket.assigns.iva_number},
        include_invoice_info
      )

    {
      :noreply,
      socket
      |> assign(:include_invoice_info, include_invoice_info)
      |> assign_payment_form(Map.put(changeset, :action, :validate))
    }
  end

  @impl true
  def handle_event("validate-payment", %{"payment" => payment_params}, socket) do
    phone = Map.get(payment_params, "mb_way_phone", "")
    iva_number = Map.get(payment_params, "iva_number", "")

    changeset =
      payment_changeset(
        %{mb_way_phone: phone, iva_number: iva_number},
        socket.assigns.include_invoice_info
      )
      |> Map.put(:action, :validate)

    {
      :noreply,
      socket
      |> assign(:mb_way_phone, phone)
      |> assign(:iva_number, iva_number)
      |> assign_payment_form(changeset)
    }
  end

  @impl true
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
      order_data = %{
        "phone_number" => phone,
        "tax_id" => if(socket.assigns.include_invoice_info, do: iva_number, else: "")
      }

      case Billing.start_payment(:mbway, socket.assigns.ticket.id, order_data) do
        {:ok, {:ok, payment}} ->
          {:noreply, push_navigate(socket, to: ~p"/checkout/payment/#{payment.order_id}")}

        {:error, _reason} ->
          {:noreply,
           socket
           |> put_flash(
              :error,
             gettext("Falha ao iniciar o pagamento. Por favor, tenta novamente mais tarde.")
           )
           |> assign_payment_form(changeset)}
      end
    else
      {:noreply, assign_payment_form(socket, changeset)}
    end
  end

  def handle_event("cancel-payment", _params, socket) do
    case Tickets.delete_ticket(socket.assigns.ticket) do
      {:ok, _ticket} ->
        {:noreply,
         socket
         |> put_flash(:success, gettext("Pagamento cancelado com sucesso."))
         |> push_navigate(to: ~p"/checkout/choose_ticket")}

      {:error, %Ecto.Changeset{}} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Algo de errado aconteceu."))}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("O bilhete já foi removido."))
         |> push_navigate(to: ~p"/checkout/choose_ticket")}
    end
  end

  defp assign_payment_form(socket, %Changeset{} = changeset) do
    form = to_form(changeset, as: :payment)

    socket
    |> assign(:payment_form, form)
    |> assign(:payment_changeset, changeset)
  end

  defp payment_changeset(attrs, include_invoice_info) do
    types = %{mb_way_phone: :string, iva_number: :string}

    {%{}, types}
    |> Changeset.cast(attrs, Map.keys(types))
    |> Changeset.validate_required([:mb_way_phone])
    |> validate_pt_phone(:mb_way_phone)
    |> maybe_validate_nif(include_invoice_info)
  end

  defp maybe_validate_nif(changeset, true) do
    changeset
    |> Changeset.validate_required([:iva_number])
    |> validate_pt_nif(:iva_number)
  end

  defp maybe_validate_nif(changeset, false), do: changeset

  defp valid_pt_phone?(phone) do
    normalized = phone |> String.trim() |> String.replace(~r/\s+/, "")
    Regex.match?(~r/^(?:\+351|351)?9\d{8}$/, normalized)
  end

  defp validate_pt_phone(changeset, field) do
    Changeset.validate_change(changeset, field, fn _, value ->
      if value in [nil, ""] or valid_pt_phone?(value) do
        []
      else
        [{field, "invalid phone number"}]
      end
    end)
  end

  defp validate_pt_nif(changeset, field) do
    Changeset.validate_change(changeset, field, fn _, value ->
      if value in [nil, ""] or valid_pt_nif?(value) do
        []
      else
        [{field, "invalid NIF"}]
      end
    end)
  end

  defp valid_pt_nif?(nif) do
    normalized = nif |> String.trim() |> String.replace(~r/\s+/, "")

    with true <- Regex.match?(~r/^\d{9}$/, normalized),
         digits <- normalized |> String.graphemes() |> Enum.map(&String.to_integer/1),
         [check | rest] <- Enum.reverse(digits) do
      sum =
        rest
        |> Enum.reverse()
        |> Enum.with_index()
        |> Enum.reduce(0, fn {digit, index}, acc -> acc + digit * (9 - index) end)

      expected = rem(11 - rem(sum, 11), 11)
      (expected == 10 && check == 0) || check == expected
    else
      _ -> false
    end
  end
end
