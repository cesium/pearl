defmodule PearlWeb.Backoffice.EventMealLive.FormComponent do
  use PearlWeb, :live_component

  alias Pearl.Tickets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-lg font-medium leading-6 text-gray-900">
        {@title}
      </h2>

      <.form
        for={@form}
        id="event_meal-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="mt-4 space-y-4"
      >
        <.input field={@form[:date]} type="date" label="Date" />
        <div class="flex flex-row gap-4">
          <.input field={@form[:start_time]} type="time" label="Start Time" />
          <.input field={@form[:end_time]} type="time" label="End Time" />
        </div>
        <.input
          field={@form[:meal_type]}
          type="select"
          label="Meal Type"
          options={["Breakfast","Lunch", "Coffee Break", "Dinner"]}
          prompt="Select a meal type"
        />
        <.input field={@form[:description]} type="text" label="Description" />

        <div class="flex justify-end gap-2">
          <.button type="submit" phx-disable-with="Saving...">Save</.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{event_meal: event_meal} = assigns, socket) do
    changeset = Tickets.change_event_meal(event_meal)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"event_meal" => event_meal_params}, socket) do
    changeset =
      socket.assigns.event_meal
      |> Tickets.change_event_meal(event_meal_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"event_meal" => event_meal_params}, socket) do
    save_event_meal(socket, socket.assigns.action, event_meal_params)
  end

  defp save_event_meal(socket, :edit, event_meal_params) do
    case Tickets.update_event_meal(socket.assigns.event_meal, event_meal_params) do
      {:ok, event_meal} ->
        notify_parent({:saved, event_meal})

        {:noreply,
         socket
         |> put_flash(:info, "Event meal updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_event_meal(socket, :new, event_meal_params) do
    case Tickets.create_event_meal(event_meal_params) do
      {:ok, event_meal} ->
        notify_parent({:saved, event_meal})

        {:noreply,
         socket
         |> put_flash(:info, "Event meal created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
