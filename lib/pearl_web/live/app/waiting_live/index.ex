defmodule PearlWeb.App.WaitingLive.Index do
  use PearlWeb, :app_view

  alias Pearl.Event
  alias Pearl.Tickets
  import PearlWeb.Components.Ticket

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-[calc(100vh-200px)] flex flex-col justify-center items-center gap-8">
      <div>
        <h1 class="text-center text-2xl sm:text-4xl uppercase bo">
          {gettext("À espera que o evento comece!")}
        </h1>
      </div>
      <.ticket
        class="flex justify-center h-[100px] md:h-[250px]!"
        svg_class="h-full!"
        attendee={@attendee}
        ticket_type={@ticket_type}
      />
      <div
        id="seconds-remaining"
        class="text-center text-4xl sm:text-6xl uppercase"
        phx-hook="Countdown"
      >
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if Event.event_started?() do
      {:ok,
       socket
       |> push_navigate(to: ~p"/app")}
    else
      if connected?(socket) do
        Event.subscribe_to_start_time_update("start_time")
      end

      ticket = Tickets.get_user_ticket(socket.assigns.current_user.id)

      {:ok,
       socket
       |> assign(:event_started, false)
       |> assign(:attendee, socket.assigns.current_user.name)
       |> assign(:ticket_type, ticket.ticket_type.name)
       |> push_event("start-countdown", %{end_time: Event.get_event_start_time!()})}
    end
  end

  @impl true
  def handle_info({"start_time", value}, socket) do
    {:noreply,
     socket
     |> push_event("start-countdown", %{end_time: value})}
  end
end
