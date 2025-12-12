defmodule PearlWeb.Checkout.TicketInformationsLive do
  use PearlWeb, :checkout_view

  # alias Pearl.Accounts
  alias Pearl.Tickets
  alias Pearl.Tickets.Ticket

  def mount(_params, %{"ticket_type_id" => ticket_type_id}, socket) do
    {:ok,
     socket
     |> assign(:ticket_data, %{})
     |> assign(:ticket_type_id, ticket_type_id)
     |> assign(:form, to_form(Tickets.change_ticket(%Ticket{})))
     |> assign(:verified_account, false)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :precautions, _params) do
    changeset = Tickets.change_ticket(%Ticket{}, socket.assigns.ticket_data)

    socket
    |> assign(:current_step, :precautions)
    |> assign(:form, to_form(changeset))
  end

  def apply_action(socket, :informations, _params) do
    changeset = Tickets.change_ticket(%Ticket{}, socket.assigns.ticket_data)

    socket
    |> assign(:current_step, :informations)
    |> assign(:form, to_form(changeset))
  end

  def apply_action(socket, :conclusion, _params) do
    changeset = Tickets.change_ticket(%Ticket{}, socket.assigns.ticket_data)

    socket
    |> assign(:current_step, :conclusion)
    |> assign(:form, to_form(changeset))
  end

  def handle_event("validate", params, socket) do
    ticket = Map.get(params, "ticket", params)

    ticket_data = Map.merge(socket.assigns.ticket_data, ticket)

    changeset =
      %Ticket{}
      |> apply_step_validation(socket.assigns.current_step, ticket_data)

    {:noreply,
     socket
     |> assign(:ticket_data, ticket_data)
     |> assign(:form, to_form(changeset, action: :validate))}
  end

  def handle_event("ticket_data_loaded", %{"data" => data}, socket) when is_map(data) do
    changeset = Tickets.change_ticket(%Ticket{}, data)

    {:noreply,
     socket
     |> assign(:ticket_data, data)
     |> assign(:form, to_form(changeset))}
  end

  def handle_event("ticket_data_loaded", _, socket), do: {:noreply, socket}

  def handle_event("prev", _, socket) do
    prev_route = get_prev_route(socket.assigns.current_step)
    {:noreply, push_patch(socket, to: prev_route)}
  end

  def handle_event("next", _, socket) do
    changeset =
      %Ticket{}
      |> apply_step_validation(socket.assigns.current_step, socket.assigns.ticket_data)

    if changeset.valid? do
      next_route = get_next_route(socket.assigns.current_step)
      {:noreply, push_patch(socket, to: next_route)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Please fill in all required fields")
       |> assign(:form, to_form(changeset, action: :validate))}
    end
  end

  def handle_event("remove_response", %{"value" => field}, socket) do
    ticket_data = Map.delete(socket.assigns.ticket_data, field)
    changeset = Tickets.change_ticket(%Ticket{}, ticket_data)

    {:noreply,
     socket
     |> assign(:ticket_data, ticket_data)
     |> assign(:form, to_form(changeset, action: :validate))}
  end

  def handle_event("payment", _, socket) do
    if socket.assigns.verified_account do
      user_id = socket.assigns.current_user.id
      ticket_type_id = socket.assigns.ticket_type_id

      ticket_attrs =
        socket.assigns.ticket_data
        |> Map.put("paid", false)
        |> Map.put("user_id", user_id)
        |> Map.put("ticket_type_id", ticket_type_id)
        |> Map.update("has_attended_enei_before", false, fn val -> val == "Yes" end)

      # ISSO AQUI VAI SER ACRESCENTADO QUANDO EU TIVER O REGISTER FORM DO GUI
      # case Accounts.create_attendee() do
      #  {:ok, _attendee} -> the other case below
      #
      #  {:error, changeset} -> handle_user_error(changeset)
      # end

      case Tickets.create_ticket(ticket_attrs) do
        {:ok, _ticket} ->
          {:noreply,
           socket
           |> push_navigate(to: ~p"/checkout/payment")}

        {:error, changeset} ->
          {:noreply,
           socket
           |> put_flash(:error, "Failed to proccess your ticket")
           |> assign(:form, to_form(changeset, action: :validate))}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "Email not verified")}
    end
  end

  # defp get_prev_route(:precautions), do: ~p"/register"
  defp get_prev_route(:informations), do: ~p"/checkout/precautions"
  defp get_prev_route(:conclusion), do: ~p"/checkout/informations"

  defp get_next_route(:precautions), do: ~p"/checkout/informations"
  defp get_next_route(:informations), do: ~p"/checkout/conclusion"
  defp get_next_route(:conclusion), do: ~p"/checkout/payment"

  defp apply_step_validation(changeset, :precautions, ticket_data) do
    changeset |> Tickets.change_precautions(ticket_data)
  end

  defp apply_step_validation(changeset, :informations, ticket_data) do
    changeset |> Tickets.change_informations(ticket_data)
  end

  defp apply_step_validation(changeset, :conclusion, ticket_data) do
    changeset |> Tickets.change_ticket(ticket_data)
  end
end
