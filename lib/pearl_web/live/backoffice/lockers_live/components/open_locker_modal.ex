defmodule PearlWeb.Backoffice.LockersLive.Components.OpenLockerModal do
  @moduledoc """
  Modal that shows locker details and stored items.
  """

  use PearlWeb, :component

  import PearlWeb.Components.Button
  import PearlWeb.Components.EnsurePermissions
  import PearlWeb.Components.Modal
  import PearlWeb.Components.Page

  attr :live_action, :atom, required: true
  attr :locker, :map, required: true
  attr :user, :map, required: true
  attr :current_user, :map, required: true
  attr :attendee, :map, required: true
  attr :session_id, :string, default: nil
  attr :locker_items, :list, required: true

  def open_locker_modal(assigns) do
    ~H"""
    <.modal
      :if={@live_action in [:open_locker]}
      id="open-locker-modal"
      show
      on_cancel={JS.push("close-locker-modal")}
    >
      <.page title={
        gettext("%{user_name} - Locker %{locker_number}",
          locker_number: @locker.number,
          user_name: @user.name
        )
      }>
        <:actions>
          <.ensure_permissions user={@current_user} permissions={%{"attendee_lockers" => ["edit"]}}>
            <.link patch={~p"/dashboard/attendee_lockers/#{@attendee.id}/#{@session_id}/new_item"}>
              <.backoffice_button>New Item</.backoffice_button>
            </.link>
          </.ensure_permissions>
        </:actions>
        <div class="mx-auto grid w-full max-w-5xl grid-cols-1 gap-4 md:grid-cols-3">
          <PearlWeb.Backoffice.LockersLive.Components.LockerItem.locker_item
            :for={item <- @locker_items}
            item={item}
          />
        </div>

        <div
          :if={Enum.empty?(@locker_items)}
          class="rounded-xl border border-lightShade dark:border-darkShade p-6"
        >
          <p class="text-sm text-center font-medium text-dark/60">
            {gettext("No items were added to this locker yet.")}
          </p>
        </div>
      </.page>
    </.modal>
    """
  end
end
