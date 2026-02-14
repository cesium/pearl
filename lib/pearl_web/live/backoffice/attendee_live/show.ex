defmodule PearlWeb.Backoffice.AttendeeLive.Show do
  use PearlWeb, :backoffice_view

  alias Pearl.Accounts

  import PearlWeb.Components.{Button, Modal}

  on_mount {PearlWeb.StaffRoles,
            show: %{"attendees" => ["show"]}, edit: %{"attendees" => ["edit"]}}

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:current_page, :attendees)}
  end

  @spec handle_params(map(), any(), map()) :: {:noreply, map()}
  def handle_params(%{"id" => attendee_id} = params, _, socket) do
    attendee =
      Accounts.get_attendee!(attendee_id, preloads: [:user])
      |> Pearl.Repo.preload(user: [ticket: :ticket_type])

    {:noreply,
     socket
     |> assign(:attendee, attendee)
     |> assign(:params, params)}
  end

  defp get_disabilities_text(value) do
    case value do
      nil -> "None"
      value -> value
    end
  end

  defp get_allergens_text(value) do
    case value do
      nil -> "None"
      "none" -> "No allergens"
      value -> value
    end
  end

  defp get_diet_text(value) do
    case value do
      "no_restrictions" -> "Dieta sem restrições"
      "vegetarian" -> "Dieta vegetariana"
      "vegan" -> "Dieta vegan"
      _ -> "None"
    end
  end

  defp get_intended_transport_to_enei_text(value) do
    case value do
      "own_vehicle" -> "Vou no meu próprio veículo"
      "someone_else" -> "Vou de boleia no veículo de outra pessoa"
      "external" -> "Vou de transporte coletivo externo ao ENEI (autocarro, comboio ou avião)"
      "taxi_or_tvde" -> "Vou recorrer a um serviço de táxi ou TVDE"
      "walking" -> "Vou a pé"
      _ -> "None"
    end
  end

  defp get_has_attended_enei_before_text(value) do
    case value do
      "no" -> "No"
      "yes_elsewhere" -> "Sim, incluindo uma ou mais edições em Braga"
      "yes_braga" -> "Sim, mas nunca uma edição em Braga"
      _ -> "None"
    end
  end
end
