defmodule PearlWeb.Backoffice.TicketsLive.TicketTypesLive.PerksLive.Index do
  use PearlWeb, :live_component

  alias Pearl.Perks
  import PearlWeb.Components.EnsurePermissions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title}>
        <:actions>
          <.ensure_permissions user={@current_user} permissions={%{"tickets" => ["edit"]}}>
            <.link navigate={~p"/dashboard/tickets/ticket_types/perks/new"}>
              <.backoffice_button>New Perk</.backoffice_button>
            </.link>
          </.ensure_permissions>
        </:actions>
        <ul
          id="perks"
          class="h-96 mt-8 pb-8 flex flex-col space-y-2 overflow-y-auto"
          phx-update="stream"
        >
          <li
            :for={{_, perk} <- @streams.perks}
            id={"perk-" <> perk.id}
            class="even:bg-lightShade/20 dark:even:bg-darkShade/20 py-4 px-4 flex flex-row justify-between"
          >
            <div class="flex flex-row gap-2 items-center">
              {perk.name}
              <%= if not perk.active do %>
                <span class="border border-amber-600 rounded-full text-xs text-amber-800 px-1 bg-amber-200">
                  Inactive
                </span>
              <% end %>
            </div>
            <p class="text-dark dark:text-light flex flex-row justify-between gap-2">
              <.ensure_permissions user={@current_user} permissions={%{"tickets" => ["edit"]}}>
                <.link navigate={~p"/dashboard/tickets/ticket_types/perks/#{perk.id}/edit"}>
                  <.icon name="hero-pencil" class="w-5 h-4" />
                </.link>
                <.link
                  phx-click={JS.push("toggle_archive", value: %{id: perk.id})}
                  data-confirm="Are you sure?"
                  phx-target={@myself}
                >
                  <%= if not perk.active do %>
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
     |> stream(:perks, Perks.list_perks())}
  end

  @impl true
  def handle_event("toggle_archive", %{"id" => id}, socket) do
    perk = Perks.get_perk!(id)

    if perk.active do
      {:ok, _} = Perks.archive_perk(perk)
    else
      {:ok, _} = Perks.unarchive_perk(perk)
    end

    {:noreply, socket |> stream(:perks, Perks.list_perks())}
  end
end
