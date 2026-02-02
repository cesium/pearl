defmodule PearlWeb.Checkout.TicketInformationsLive do
  use PearlWeb, :checkout_view

  # alias Pearl.Accounts
  alias Pearl.{Tickets, TicketTypes}
  alias Pearl.Tickets.Ticket
  import PearlWeb.Components.Button

  def mount(_params, session, socket) do
    ticket_types = TicketTypes.list_ticket_types()

    ticket_type_id =
      case Map.get(session, "ticket_type_id") do
        nil ->
          case ticket_types do
            [head | _] -> head.id
            [] -> nil
          end

        id ->
          id
      end

    ticket_data = %{"ticket_type_id" => ticket_type_id}

    {:ok,
     socket
     |> assign(:ticket_data, ticket_data)
     |> assign(:ticket_type_id, ticket_type_id)
     |> assign(:ticket_types, ticket_types)
     |> assign(:form, to_form(Tickets.change_ticket(%Ticket{}, ticket_data)))
     |> assign(:verified_account, true)
     |> assign(:active_orbs, [])}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :choose_ticket, _params) do
    changeset = Tickets.change_ticket(%Ticket{}, socket.assigns.ticket_data)

    socket
    |> assign(:ticket_types, socket.assigns.ticket_types)
    |> assign(:current_step, :choose_ticket)
    |> assign(:form, to_form(changeset))
  end

  def apply_action(socket, :precautions, _params) do
    changeset =
      %Ticket{}
      |> apply_step_validation(:choose_ticket, socket.assigns.ticket_data)

    if changeset.valid? do
      socket
      |> assign(:current_step, :precautions)
      |> assign(:form, to_form(changeset))
      |> assign(:active_orbs, [%{disabilities: "active"}, %{allergens: "active"}])
    else
      socket
      |> put_flash(:error, "Por favor completa todos os campos obrigatórios antes de prosseguir.")
      |> push_patch(to: ~p"/checkout/choose_ticket")
    end
  end

  def apply_action(socket, :informations, _params) do
    changeset =
      %Ticket{}
      |> apply_step_validation(:precautions, socket.assigns.ticket_data)

    if changeset.valid? do
      socket
      |> assign(:current_step, :informations)
      |> assign(:form, to_form(changeset))
      |> assign(:active_orbs, [
        %{disabilities: "inactive"},
        %{allergens: "inactive"},
        %{tshirt_size: "active"},
        %{diet: "active"},
        %{transport: "active"},
        %{attended: "active"},
        %{user: "active"}
      ])
    else
      socket
      |> put_flash(:error, "Por favor completa todos os campos obrigatórios antes de prosseguir.")
      |> push_patch(to: ~p"/checkout/precautions")
    end
  end

  def apply_action(socket, :conclusion, _params) do
    changeset =
      %Ticket{}
      |> apply_step_validation(:informations, socket.assigns.ticket_data)

    if changeset.valid? do
      socket
      |> assign(:current_step, :conclusion)
      |> assign(:form, to_form(changeset))
      |> assign(:active_orbs, [
        %{disabilities: "active"},
        %{allergens: "active"},
        %{tshirt_size: "active"},
        %{diet: "active"},
        %{transport: "active"},
        %{attended: "active"},
        %{user: "active"}
      ])
    else
      socket
      |> put_flash(
        :error,
        "Por favor completa todos os campos obrigatórios antes de seguir para a conclusão."
      )
      |> push_patch(to: ~p"/checkout/choose_ticket")
    end
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
       |> put_flash(:error, "Por favor completa todos os campos obrigatórios")
       |> assign(:form, to_form(changeset, action: :validate))}
    end
  end

  def handle_event("remove_response", %{"field" => field}, socket) do
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

      ticket_attrs =
        socket.assigns.ticket_data
        |> Map.put("paid", false)
        |> Map.put("user_id", user_id)
        |> Map.update("has_attended_enei_before", nil, fn val -> to_string(val || "") end)
        |> then(fn attrs ->
          case Map.get(attrs, "has_allergens") do
            "no" -> Map.put(attrs, "allergens", "none")
            "yes" -> attrs
            _ -> Map.put(attrs, "allergens", "none")
          end
        end)

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

  defp get_prev_route(:precautions), do: ~p"/checkout/choose_ticket"
  defp get_prev_route(:informations), do: ~p"/checkout/precautions"
  defp get_prev_route(:conclusion), do: ~p"/checkout/informations"

  defp get_next_route(:choose_ticket), do: ~p"/checkout/precautions"
  defp get_next_route(:precautions), do: ~p"/checkout/informations"
  defp get_next_route(:informations), do: ~p"/checkout/conclusion"
  defp get_next_route(:conclusion), do: ~p"/checkout/payment"

  defp apply_step_validation(changeset, :choose_ticket, ticket_data) do
    changeset |> Tickets.change_ticket_type(ticket_data)
  end

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
