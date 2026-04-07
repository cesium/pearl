defmodule PearlWeb.Backoffice.ScheduleLive.CalendarPictures.Index do
  @moduledoc false
  use PearlWeb, :live_component

  alias Pearl.Event

  import PearlWeb.Components.EnsurePermissions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} stack_header_on_mobile>
        <ul
          id="calendar-pictures"
          class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto"
          phx-update="stream"
        >
          <li
            :for={date <- @days}
            id={"day#{date.day}"}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 py-4 px-4 flex flex-row justify-between"
          >
            <div class="flex flex-row gap-2 items-center">
              Day {date.day}
            </div>
            <p class="text-dark dark:text-light flex flex-row justify-between gap-2">
              <.ensure_permissions user={@current_user} permissions={%{"companies" => ["edit"]}}>
                <.link navigate={
                  ~p"/dashboard/schedule/activities/calendar_pictures/#{Date.to_iso8601(date)}/edit"
                }>
                  <.icon name="hero-pencil" class="w-5 h-5" />
                </.link>
              </.ensure_permissions>
            </p>
          </li>
          <div class="only:flex hidden h-full items-center justify-center">
            <p class="text-center text-lightMuted dark:text-darkMuted mt-8">
              {gettext("No activity categories found")}
            </p>
          </div>
        </ul>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(days: list_event_days())}
  end

  defp list_event_days do
    Date.range(Event.get_event_start_date(), Event.get_event_end_date()) |> Enum.to_list()
  end
end
