defmodule PearlWeb.Backoffice.EventMealLive.Index do
  use PearlWeb, :backoffice_view

  alias Pearl.Tickets
  alias Pearl.Tickets.EventMeal

  import PearlWeb.Components.Page
  import PearlWeb.Components.Modal
  import PearlWeb.Components.Table

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:params, %{})
     |> assign(:meta, %Flop.Meta{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {event_meals, meta} = Tickets.list_event_meals(params)

    {:noreply,
     socket
     |> assign(:params, params)
     |> assign(:meta, meta)
     |> stream(:event_meals, event_meals, reset: true)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event Meal")
    |> assign(:event_meal, Tickets.get_event_meal!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event Meal")
    |> assign(:event_meal, %EventMeal{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Event Meals")
    |> assign(:event_meal, nil)
  end

  @impl true
  def handle_info({PearlWeb.Backoffice.EventMealLive.FormComponent, {:saved, event_meal}}, socket) do
    {:noreply, stream_insert(socket, :event_meals, event_meal)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event_meal = Tickets.get_event_meal!(id)
    {:ok, _} = Tickets.delete_event_meal(event_meal)

    {:noreply, stream_delete(socket, :event_meals, event_meal)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.page title={@page_title}>
      <:actions>
        <div class="flex flex-row gap-4 justify-center items-center">
          <.ensure_permissions scope="meals" action="edit">
            <.link patch={~p"/dashboard/meals/new"}>
              <.backoffice_button>New Event Meal</.backoffice_button>
            </.link>
          </.ensure_permissions>
        </div>
      </:actions>

      <div class="py-4">
        <.table id="event_meals-table" items={@streams.event_meals} meta={@meta} params={@params}>
          <:col :let={{_id, event_meal}} label="Date">{event_meal.date}</:col>
          <:col :let={{_id, event_meal}} label="Time">
            <%= if event_meal.start_time && event_meal.end_time do %>
              {Calendar.strftime(event_meal.start_time, "%H:%M")} - {Calendar.strftime(
                event_meal.end_time,
                "%H:%M"
              )}
            <% end %>
          </:col>
          <:col :let={{_id, event_meal}} label="Type">{event_meal.meal_type}</:col>
          <:col :let={{_id, event_meal}} label="Description">{event_meal.description}</:col>
          <:action :let={{id, event_meal}}>
            <div class="flex flex-row gap-2">
              <.link patch={~p"/dashboard/meals/#{event_meal}/edit"}>
                <.icon name="hero-pencil" class="w-5 h-5" />
              </.link>
              <.link
                phx-click={JS.push("delete", value: %{id: event_meal.id}) |> hide("##{id}")}
                data-confirm="Are you sure?"
              >
                <.icon name="hero-trash" class="w-5 h-5" />
              </.link>
            </div>
          </:action>
        </.table>
      </div>

      <.modal
        :if={@live_action in [:new, :edit]}
        id="event_meal-modal"
        show
        on_cancel={JS.patch(~p"/dashboard/meals")}
      >
        <.live_component
          module={PearlWeb.Backoffice.EventMealLive.FormComponent}
          id={@event_meal.id || :new}
          title={@page_title}
          action={@live_action}
          event_meal={@event_meal}
          patch={~p"/dashboard/meals"}
        />
      </.modal>
    </.page>
    """
  end
end
