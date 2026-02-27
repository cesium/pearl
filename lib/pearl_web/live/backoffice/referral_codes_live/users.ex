defmodule PearlWeb.Backoffice.ReferralsLive.Users do

  use PearlWeb, :live_component

  def render(assigns) do
    ~H"""
      <div>
        <.header>
          {@title}
          <:subtitle>
            {gettext("Attendees using referral code: ")} <span class="font-bold">{@referral.code}</span>
          </:subtitle>
        </.header>

        <div class="mt-6">
          <%= if Enum.empty?(@referral.attendees) do %>
            <div class="text-center py-12">
              <.icon name="hero-users" class="mx-auto h-12 w-12 text-gray-400" />
              <p class="mt-2 text-sm text-gray-500">
                {gettext("No attendees have used this referral code yet")}
              </p>
            </div>
          <% else %>
            <div class="bg-white shadow overflow-hidden sm:rounded-md">
              <div  class="divide-y divide-lightMuted/20">
                <%= for attendee <- @referral.attendees do %>
                  <div class="px-6 py-4 hover:bg-gray-50">
                    <div class="flex items-center justify-between">
                      <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-3">
                          <div class="shrink-0">
                          <.link navigate={~p"/dashboard/attendees/#{attendee.id}"} class="shrink-0">
                            <div class="h-10 w-10 rounded-full bg-primary-100 flex items-center justify-center hover:bg-primary-200 border border-dark/20 cursor-pointer">
                              <span class="text-primary-700 font-semibold text-sm">
                                {String.first(attendee.user.name)}
                              </span>
                            </div>
                          </.link>
                          </div>
                          <div class="flex-1">
                            <p class="text-sm font-medium text-gray-900">
                              {attendee.user.name}
                            </p>
                            <p class="text-sm text-gray-500">
                              {attendee.user.email}
                            </p>
                          </div>
                        </div>
                      </div>
                      <div class="flex items-center gap-6 text-sm">
                        <div class="text-center">
                          <p class="font-semibold text-dark/80">{attendee.tokens}</p>
                          <p class="text-xs text-lightMuted">Tokens</p>
                        </div>
                        <div class="text-center">
                          <p class="font-semibold text-dark/80">{attendee.entries}</p>
                          <p class="text-xs text-lightMuted">Entries</p>
                        </div>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>

            <div class="mt-4 flex items-center justify-between px-4 py-3 bg-gray-50 rounded-lg">
              <p class="text-sm font-medium text-gray-700">
                {gettext("Total attendees:")}
              </p>
              <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold bg-primary-100 text-primary-800">
                {length(@referral.attendees)}
              </span>
            </div>
          <% end %>
        </div>
      </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_attendees()
    }
  end

  defp assign_attendees(socket) do
    referral =
      socket.assigns.referral
      |> Pearl.Repo.preload(attendees: [:user])

    assign(socket, :referral, referral)
  end

end
