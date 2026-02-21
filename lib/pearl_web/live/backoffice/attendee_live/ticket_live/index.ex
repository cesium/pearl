defmodule PearlWeb.Backoffice.AttendeeLive.TicketLive.Index do
  use PearlWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h3 class="text-lg font-semibold mb-4">{@title}</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-6">
          {gettext("View ticket information.")}
        </p>
      </div>

      <div class="space-y-4">
        <.ticket_field :for={field <- @ticket_fields} title={field.title} value={field.value} />
      </div>
    </div>
    """
  end

  defp ticket_field(assigns) do
    ~H"""
    <div class="border-b pb-3 border-primary">
      <p class="text-xs font-medium text-darkMuted uppercase tracking-wider mb-1">
        {@title}
      </p>
      <p class="text-sm">{@value}</p>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    ticket = assigns.attendee.user.ticket

    ticket_fields = [
      %{title: gettext("Ticket Type"), value: ticket.ticket_type.name},
      %{title: gettext("Disabilities"), value: get_disabilities_text(ticket.disabilities)},
      %{title: gettext("Allergens"), value: get_allergens_text(ticket.allergens)},
      %{title: gettext("Diet"), value: get_diet_text(ticket.diet)},
      %{title: gettext("T-Shirt Size"), value: ticket.tshirt_size},
      %{title: gettext("University"), value: assigns.attendee.user.university || "No response"},
      %{title: gettext("City"), value: assigns.attendee.user.city || "No response"},
      %{
        title: gettext("Transport to ENEI"),
        value: get_intended_transport_to_enei_text(ticket.intended_transport_to_enei)
      },
      %{
        title: gettext("Has Attended ENEI Before"),
        value: get_has_attended_enei_before_text(ticket.has_attended_enei_before)
      }
    ]

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:ticket_fields, ticket_fields)}
  end

  defp get_disabilities_text(value) do
    case value do
      nil -> "No disabilities"
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
      _ -> "No response"
    end
  end

  defp get_intended_transport_to_enei_text(value) do
    case value do
      "own_vehicle" -> "I will use my own vehicle"
      "someone_else" -> "I will get a ride in someone else's vehicle"
      "external" -> "I will use public transportation outside ENEI (bus, train, or plane)"
      "taxi_or_tvde" -> "I will use a taxi or ride-hailing service"
      "walking" -> "I will walk"
      _ -> "No response"
    end
  end

  defp get_has_attended_enei_before_text(value) do
    case value do
      "no" -> "No"
      "yes_elsewhere" -> "Yes, including one or more editions in Braga"
      "yes_braga" -> "Yes, but never an edition in Braga"
      _ -> "No response"
    end
  end
end
