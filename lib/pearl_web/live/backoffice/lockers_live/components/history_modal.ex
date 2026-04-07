defmodule PearlWeb.Backoffice.LockersLive.Components.HistoryModal do
  @moduledoc """
  Modal that lists all locker sessions for an attendee.
  """

  use PearlWeb, :component

  import PearlWeb.Components.Modal

  attr :live_action, :atom, required: true
  attr :attendee, :map, required: true
  attr :user, :map, required: true
  attr :sessions, :list, default: []

  def history_modal(assigns) do
    ~H"""
    <.modal
      :if={@live_action in [:history]}
      id="history-locker-modal"
      show
      body_class="bg-light p-8 sm:p-14 shadow-zinc-700/10 shadow-lg rounded-2xl w-full max-w-3xl mx-auto"
      on_cancel={JS.patch(~p"/dashboard/attendee_lockers/#{@attendee.id}")}
    >
      <div class="space-y-6">
        <div class="space-y-2">
          <h2 class="text-xl font-semibold">
            {gettext("Locker History")}
          </h2>

          <p class="text-sm text-dark/70">
            {gettext("Sessions for %{user}", user: @user.name)}
          </p>
        </div>

        <%= if Enum.empty?(@sessions) do %>
          <p class="rounded-xl border border-dashed border-dark/20 p-6 text-center text-sm text-dark/60">
            {gettext("No locker sessions found for this attendee.")}
          </p>
        <% else %>
          <ul class="space-y-3 max-h-[60vh] overflow-y-auto pr-1">
            <li :for={session <- @sessions}>
              <.link
                patch={~p"/dashboard/attendee_lockers/#{@attendee.id}/#{session.id}"}
                class="block rounded-xl border border-dark/10 bg-dark/5 p-4 transition-colors hover:bg-dark/10"
              >
                <div class="flex items-center justify-between gap-3">
                  <p class="font-semibold text-dark">
                    {gettext("Locker %{number}", number: session.locker_number)}
                  </p>

                  <span class={status_class(session.active)}>
                    {if session.active, do: gettext("Active"), else: gettext("Closed")}
                  </span>
                </div>

                <div class="mt-3 grid grid-cols-1 gap-1 text-sm text-dark/70 sm:grid-cols-2">
                  <p>
                    <span class="font-semibold">{gettext("Assigned")}: </span>{format_datetime(
                      session.inserted_at
                    )}
                  </p>

                  <p>
                    <span class="font-semibold">{gettext("Closed")}: </span>{format_datetime(
                      session.updated_at
                    )}
                  </p>
                </div>
              </.link>
            </li>
          </ul>
        <% end %>
      </div>
    </.modal>
    """
  end

  defp status_class(true) do
    "inline-flex items-center rounded-full bg-success-700/10 px-2.5 py-1 text-xs font-semibold uppercase tracking-wide text-success-700"
  end

  defp status_class(false) do
    "inline-flex items-center rounded-full bg-dark/10 px-2.5 py-1 text-xs font-semibold uppercase tracking-wide text-dark/70"
  end

  defp format_datetime(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%d-%m-%Y %H:%M")
  end

  defp format_datetime(_), do: "-"
end
