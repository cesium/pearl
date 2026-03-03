defmodule PearlWeb.Backoffice.ReferralsLive.Users do
  use PearlWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          <span>Attendees using referral code: <span class="font-bold">{@referral.code}</span></span>
        </:subtitle>
      </.header>

      <div class="mt-4 mb-6">
        <label class="block text-sm text-dark-muted mb-2">
          Referral Link
        </label>
        <div class="flex gap-2">
          <input
            type="text"
            readonly
            value={referral_url(@referral.code)}
            class="flex-1 rounded-md border-gray-300 bg-gray-50 text-sm"
            id={"referral-url-#{@id}"}
          />
        </div>
      </div>

      <div class="mt-6">
        <%= if Enum.empty?(@referral.attendees) do %>
          <div class="text-center py-12">
            <.icon name="hero-users" class="mx-auto h-12 w-12 text-dark-shade" />
            <p class="mt-2 text-sm text-lightMuted">
              No attendees have used this referral code yet
            </p>
          </div>
        <% else %>
          <div class="bg-white shadow overflow-hidden sm:rounded-md max-h-96 overflow-y-auto">
            <div class="divide-y divide-lightMuted/20">
              <%= for attendee <- @referral.attendees do %>
                <div class="px-6 py-4 hover:bg-lightMuted/10">
                  <div class="flex items-center justify-between">
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-3">
                        <div class="shrink-0">
                          <.link navigate={~p"/dashboard/attendees/#{attendee.id}"} class="shrink-0">
                            <div class="h-10 w-10 rounded-full bg-primary-100 flex items-center justify-center hover:bg-primary-200 border border-dark/20 cursor-pointer">
                              <span class="text-primary font-semibold text-sm">
                                {String.first(attendee.user.name)}
                              </span>
                            </div>
                          </.link>
                        </div>
                        <div class="flex-1">
                          <p class="text-sm text-dark-shade">
                            {attendee.user.name}
                          </p>
                          <p class="text-sm text-dark-muted">
                            {attendee.user.email}
                          </p>
                        </div>
                      </div>
                    </div>
                    <div class="flex items-center gap-6 text-sm">
                      <div class="text-center">
                        <p class="font-semibold text-dark-shade">{attendee.tokens}</p>
                        <p class="text-xs text-lightMuted">Tokens</p>
                      </div>
                      <div class="text-center">
                        <p class="font-semibold text-dark-shade">{attendee.entries}</p>
                        <p class="text-xs text-lightMuted">Entries</p>
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="mt-4 flex items-center justify-between px-4 py-3 bg-lightShade/40 rounded-lg">
            <p class="text-sm text-dark-shade">
              Total attendees:
            </p>
            <span class="inline-flex items-center px-3 py-1 text-sm font-semibold text-primary">
              {length(@referral.attendees)}
            </span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp referral_url(code) do
    url(~p"/referral/#{code}")
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_attendees()}
  end

  defp assign_attendees(socket) do
    referral =
      socket.assigns.referral
      |> Pearl.Repo.preload(attendees: [:user])

    assign(socket, :referral, referral)
  end
end
