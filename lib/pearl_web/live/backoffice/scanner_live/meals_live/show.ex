defmodule PearlWeb.Backoffice.ScannerLive.MealsLive.Show do
  use PearlWeb, :backoffice_view

  alias Pearl.{Accounts, Tickets}

  import PearlWeb.Components.{Tabs, Modal}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="-translate-y-4 sm:translate-y-0">
        <.tabs class="sm:hidden mb-4">
          <.link patch={~p"/dashboard/scanner"} class="w-full">
            <.tab class="gap-2">
              <.icon name="hero-check-badge" />
              {gettext("Badges")}
            </.tab>
          </.link>
          <.link patch={~p"/dashboard/scanner/redeems"} class="w-full">
            <.tab class="gap-2">
              <.icon name="hero-gift" />
              {gettext("Redeems")}
            </.tab>
          </.link>
          <.link patch={~p"/dashboard/scanner/meals"} class="w-full">
            <.tab active class="gap-2">
              <.icon name="hero-cake" />
              {gettext("Meals")}
            </.tab>
          </.link>
        </.tabs>
        <.page title={"#{@user.name}'s Meals"}>
          <:actions>
            <.link patch={~p"/dashboard/scanner/meals"}>
              <.backoffice_button class="flex gap-2 items-center justify-center w-full sm:w-auto">
                <.icon name="hero-qr-code" class="w-5 h-5" />
                {gettext("Scan Again")}
              </.backoffice_button>
            </.link>
          </:actions>

          <%= if @has_meals do %>
            <div class="space-y-8 py-8">
              <div :for={{date, meals} <- @grouped_meals} class="border p-4 rounded-xl">
                <h2 class="text-xl font-bold mb-4">{date}</h2>
                <ul class="space-y-4">
                  <li :for={meal <- meals} class="flex flex-row justify-between items-center">
                    <div>
                      <h3 class="font-semibold text-lg">
                        {meal.meal_type}
                        <span class="text-sm font-normal text-gray-500">({meal.description})</span>
                      </h3>
                      <p class="text-sm text-gray-500 mb-1 font-medium">
                        <%= if meal.start_time && meal.end_time do %>
                          <.icon name="hero-clock" class="w-4 h-4 inline mr-1 -mt-0.5" />
                          {Calendar.strftime(meal.start_time, "%H:%M")} - {Calendar.strftime(
                            meal.end_time,
                            "%H:%M"
                          )}
                        <% end %>
                      </p>
                      <%= if consumed = get_consumption(@consumptions, meal.id) do %>
                        <p class="flex flex-row items-center text-green-500">
                          <.icon name="hero-check" class="w-5 h-5 mr-1" />
                          {gettext("Consumed at %{time}",
                            time: relative_datetime(consumed.inserted_at)
                          )}
                        </p>
                      <% else %>
                        <p class="text-gray-500">{gettext("Available")}</p>
                      <% end %>
                    </div>

                    <div :if={!get_consumption(@consumptions, meal.id)}>
                      <span
                        :if={can_consume?(meal)}
                        phx-click="consume"
                        phx-value-id={meal.id}
                        class="w-10 h-10 flex items-center justify-center rounded-full border border-dark dark:border-light cursor-pointer hover:bg-dark/10 dark:hover:bg-light"
                      >
                        <.icon name="hero-check" class="w-6 h-6" />
                      </span>
                      <span
                        :if={!can_consume?(meal)}
                        class="w-10 h-10 flex items-center justify-center rounded-full border border-gray-300 dark:border-gray-600 text-gray-300 dark:text-gray-600 cursor-not-allowed"
                        title={
                          gettext(
                            "This meal is only available on its date between %{start} and %{end}",
                            start: Calendar.strftime(meal.start_time, "%H:%M"),
                            end: Calendar.strftime(meal.end_time, "%H:%M")
                          )
                        }
                      >
                        <.icon name="hero-check" class="w-6 h-6" />
                      </span>
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          <% else %>
            <div class="py-8 text-center text-red-500 font-semibold">
              <p>{gettext("This attendee does not have access to meals.")}</p>
            </div>
          <% end %>
        </.page>
      </div>

      <.modal
        :if={@selected_meal != nil}
        id="consume-meal-modal"
        show
        wrapper_class="px-2"
        on_cancel={JS.push("cancel-consume")}
      >
        <h1 class="font-semibold text-xl">
          {gettext("Consume %{meal} on %{date}",
            meal: @selected_meal.meal_type,
            date: @selected_meal.date
          )}
        </h1>
        <div class="flex flex-col gap-4 items-center mt-2">
          <p>
            {gettext(
              "Are you sure you want to mark this meal as consumed? This action is not reversible."
            )}
          </p>

          <div class="flex flex-row w-full gap-2">
            <.backoffice_button
              phx-click="cancel-consume"
              class="w-full flex flex-row items-center justify-center"
            >
              <.icon name="hero-x-circle" class="w-5 h-5 mr-2" />
              {gettext("Cancel")}
            </.backoffice_button>
            <.backoffice_button
              phx-click="confirm-consume"
              class="w-full flex flex-row items-center justify-center"
            >
              <.icon name="hero-check-circle" class="w-5 h-5 mr-2" />
              {gettext("Consume")}
            </.backoffice_button>
          </div>
        </div>
      </.modal>
    </div>
    """
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    attendee = Accounts.get_attendee!(id)
    user = Accounts.get_user!(attendee.user_id)
    ticket = Tickets.get_user_ticket(user.id)

    has_meals = if ticket, do: Tickets.has_meals?(ticket), else: false
    consumptions = Tickets.list_user_meal_consumptions(user.id)
    {event_meals, _meta} = Tickets.list_event_meals()
    event_meals = event_meals |> Enum.sort_by(& &1.date, Date)
    grouped_meals = Enum.group_by(event_meals, & &1.date)

    {:noreply,
     socket
     |> assign(
       :current_page,
       :scanner
     )
     |> assign(:selected_meal, nil)
     |> assign(:attendee, attendee)
     |> assign(:user, user)
     |> assign(:ticket, ticket)
     |> assign(:has_meals, has_meals)
     |> assign(:consumptions, consumptions)
     |> assign(:grouped_meals, grouped_meals)}
  end

  @impl true
  def handle_event("consume", %{"id" => id}, socket) do
    if get_consumption(socket.assigns.consumptions, id) do
      {:noreply, socket}
    else
      meal = Tickets.get_event_meal!(id)
      {:noreply, assign(socket, :selected_meal, meal)}
    end
  end

  @impl true
  def handle_event("cancel-consume", _params, socket) do
    {:noreply, assign(socket, :selected_meal, nil)}
  end

  @impl true
  def handle_event("confirm-consume", _params, socket) do
    meal = socket.assigns.selected_meal
    user_id = socket.assigns.user.id

    case Tickets.consume_meal(%{user_id: user_id, event_meal_id: meal.id}) do
      {:ok, consumption} ->
        consumptions = [consumption | socket.assigns.consumptions]

        {:noreply,
         socket
         |> assign(:selected_meal, nil)
         |> assign(:consumptions, consumptions)
         |> put_flash(:info, "Meal has been successfully consumed.")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "An error occurred while consuming the meal.")
         |> assign(:selected_meal, nil)}
    end
  end

  defp get_consumption(consumptions, event_meal_id) do
    Enum.find(consumptions, fn c -> c.event_meal_id == event_meal_id end)
  end

  defp can_consume?(meal) do
    if meal.start_time && meal.end_time do
      start_dt = NaiveDateTime.new!(meal.date, meal.start_time)

      end_dt =
        if Time.compare(meal.start_time, meal.end_time) == :gt do
          NaiveDateTime.new!(Date.add(meal.date, 1), meal.end_time)
        else
          NaiveDateTime.new!(meal.date, meal.end_time)
        end

      now = NaiveDateTime.local_now()

      NaiveDateTime.compare(now, start_dt) in [:gt, :eq] and
        NaiveDateTime.compare(now, end_dt) in [:lt, :eq]
    else
      true
    end
  end
end
