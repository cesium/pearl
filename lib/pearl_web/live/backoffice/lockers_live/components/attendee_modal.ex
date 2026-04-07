defmodule PearlWeb.Backoffice.LockersLive.Components.AttendeeModal do
  @moduledoc """
  Modal for the attendee locker status modal.
  """

  use PearlWeb, :component

  import PearlWeb.Components.{Button, Modal}

  attr :live_action, :atom, required: true
  attr :modal, :atom, required: true
  attr :user, :map, required: true
  attr :attendee, :map, required: true
  attr :active_locker, :map, default: nil

  def attendee_modal(assigns) do
    ~H"""
    <.modal
      :if={@live_action in [:show] and @modal != :assign_locker}
      id="attendee-locker-modal"
      show
      body_class="bg-light dark:bg-dark p-8 sm:p-14 shadow-zinc-700/10 shadow-lg rounded-2xl w-full max-w-lg mx-auto"
      on_cancel={JS.patch(~p"/dashboard/attendee_lockers/")}
    >
      <div class="mb-6 space-y-4">
        <h2 class="text-xl font-semibold">
          {gettext("Attendee: %{user}", user: @user.name)}
        </h2>

        <p :if={@active_locker} class="text-center">
          {gettext("This attendee is currently using")}
          <span class="font-semibold">Locker {@active_locker.number}</span>
        </p>

        <p :if={!@active_locker} class="text-center">
          {gettext("This attendee has no current active locker.")}
        </p>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <.link patch={~p"/dashboard/attendee_lockers/#{@attendee.id}/history"}>
          <.backoffice_button class="w-full">
            <span class="flex items-center justify-center gap-2">
              <.icon name="hero-clock" class="w-5 h-5" />
              {gettext("View History")}
            </span>
          </.backoffice_button>
        </.link>

        <%= if @active_locker do %>
          <.backoffice_button class="w-full" phx-click="open-locker">
            <span class="flex items-center justify-center gap-2">
              <.icon name="hero-lock-closed" class="w-5 h-5" />
              {gettext("Open Locker")}
            </span>
          </.backoffice_button>
        <% else %>
          <.backoffice_button class="w-full" phx-click="assign-locker">
            <span class="flex items-center justify-center gap-2">
              <.icon name="hero-lock-closed" class="w-5 h-5" />
              {gettext("Assign Locker")}
            </span>
          </.backoffice_button>
        <% end %>
      </div>
    </.modal>
    """
  end
end
