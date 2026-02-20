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
      "no_restrictions" -> "Diet with no restrictions"
      "vegetarian" -> "Vegetarian Diet"
      "vegan" -> "Vegan Diet"
      _ -> "None"
    end
  end

  defp get_intended_transport_to_enei_text(value) do
    case value do
      "own_vehicle" -> "I will use my own vehicle"
      "someone_else" -> "I will get a ride in someone else's vehicle"
      "external" -> "I will use public transportation outside ENEI (bus, train, or plane)"
      "taxi_or_tvde" -> "I will use a taxi or ride-hailing service"
      "walking" -> "I will walk"
      _ -> "None"
    end
  end

  defp get_has_attended_enei_before_text(value) do
    case value do
      "no" -> "No"
      "yes_elsewhere" -> "Yes, including one or more editions in Braga"
      "yes_braga" -> "Yes, but never an edition in Braga"
      _ -> "None"
    end
  end
end
