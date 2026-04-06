defmodule PearlWeb.Backoffice.LockersLive.Components.AssignLockerModal do
  @moduledoc """
  Modal to assign a free locker to an attendee.
  """

  use PearlWeb, :component

  import PearlWeb.Components.Button
  import PearlWeb.Components.Modal

  attr :modal, :atom, required: true
  attr :configured_lockers, :boolean, required: true
  attr :free_lockers, :list, required: true

  def assign_locker_modal(assigns) do
    ~H"""
    <.modal
      :if={@modal == :assign_locker}
      id="assign-locker-modal"
      show
      body_class="bg-light dark:bg-dark p-8 sm:p-14 shadow-zinc-700/10 shadow-lg rounded-2xl w-full max-w-lg mx-auto"
      on_cancel={JS.push("close-modal")}
    >
      <div class="mb-6 space-y-4">
        <h2 class="text-xl font-semibold">
          {gettext("Assign Locker")}
        </h2>

        <p class="text-center">
          {gettext(
            "This attendee does not have an active locker yet. Choose one from the available lockers below."
          )}
        </p>
      </div>

      <div class="rounded-xl border border-dashed border-lightShade dark:border-darkShade p-4">
        <%= if !@configured_lockers do %>
          <p class="text-sm md:text-base text-lightMuted dark:text-darkMuted text-center">
            {gettext("There are no lockers configured!")}
            <br /> {gettext("Please configure the ammount of max lockers first")}
          </p>
        <% else %>
          <%= if @free_lockers != [] do %>
            <ul class="space-y-2">
              <li
                :for={locker <- @free_lockers}
                key={locker.id}
                phx-click="assign-locker"
                phx-value-locker={locker.id}
                class="flex cursor-pointer hover:bg-dark/10 transition-colors duration-200 items-center gap-2 w-full p-4 bg-dark/5 border border-dark/10 rounded-xl"
              >
                <span class="size-2 bg-success-700 rounded-full animate-pulse" />
                <p class="font-semibold text-dark/70">Locker {locker.number}</p>
              </li>
            </ul>
          <% else %>
            <p class="text-sm text-lightMuted dark:text-darkMuted text-center">
              {gettext("There are no available lockers at the moment.")}
            </p>
          <% end %>
        <% end %>
      </div>

      <.backoffice_button :if={!@configured_lockers} class="w-full mt-6" phx-click="close-modal">
        {gettext("Back")}
      </.backoffice_button>
    </.modal>
    """
  end
end
