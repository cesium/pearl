defmodule PearlWeb.Backoffice.TicketsLive.TicketTypesLive.Index do
  use PearlWeb, :live_component

  alias Pearl.TicketTypes
  import PearlWeb.Components.EnsurePermissions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <:actions>
          <.ensure_permissions user={@current_user} permissions={%{"tickets" => ["edit"]}}>
            <.link navigate={~p"/dashboard/tickets/ticket_types/new"}>
              <.button>New Ticket Type</.button>
            </.link>
          </.ensure_permissions>
        </:actions>
        <ul
          id="ticket_types"
          class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto"
          phx-hook="Sorting"
          phx-update="stream"
        >
          <li
            :for={{_, ticket_type} <- @streams.ticket_types}
            id={"ticket_type-" <> ticket_type.id}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 py-4 px-4 flex flex-row justify-between"
          >
            <div class="flex flex-row gap-2 items-center">
              <.icon name="hero-bars-3" class="w-5 h-5 handle cursor-pointer ml-4" />
              {ticket_type.name}
              <%= if not ticket_type.active do %>
                <span class="border border-amber-600 rounded-full text-xs text-amber-800 px-1 bg-amber-200">Inactive</span>
              <% end %>
            </div>
            <p class="text-dark dark:text-light flex flex-row justify-between gap-2">
              <.ensure_permissions user={@current_user} permissions={%{"tickets" => ["edit"]}}>
                <.link navigate={~p"/dashboard/tickets/ticket_types/#{ticket_type.id}/edit"}>
                  <.icon name="hero-pencil" class="w-5 h-4" />
                </.link>
                <.link
                  phx-click={JS.push("toggle_archive", value: %{id: ticket_type.id})}
                  data-confirm="Are you sure?"
                  phx-target={@myself}
                >
                  <%= if not ticket_type.active do %>
                    <.icon name="hero-archive-box-arrow-down" class="w-5 h-5" />
                  <% else %>
                    <.icon name="hero-archive-box" class="w-5 h-5" />
                  <% end %>
                </.link>
              </.ensure_permissions>
            </p>
          </li>
        </ul>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> stream(:ticket_types, TicketTypes.list_ticket_types())}
  end

  def handle_event("update-sorting", %{"ids" => ids}, socket) do
    ids
    |> Enum.with_index(0)
    |> Enum.each(fn {"ticket_type-" <> id, index} ->
      id
      |> TicketTypes.get_ticket_type!()
      |> TicketTypes.update_ticket_type(%{priority: index})
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_archive", %{"id" => id}, socket) do
    ticket_type = TicketTypes.get_ticket_type!(id)

    if ticket_type.active do
      {:ok, _} = TicketTypes.archive_ticket_type(ticket_type)
    else
      {:ok, _} = TicketTypes.unarchive_ticket_type(ticket_type)
    end

    {:noreply, socket |> stream(:ticket_types, TicketTypes.list_ticket_types())}
  end
end
