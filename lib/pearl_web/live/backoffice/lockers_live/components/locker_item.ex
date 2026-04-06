defmodule PearlWeb.Backoffice.LockersLive.Components.LockerItem do
  @moduledoc """
  Locker Item card component.
  """

  use PearlWeb, :component

  alias Pearl.Uploaders.LockerItems
  import PearlWeb.Components.Button

  attr :item, :map, required: true

  def locker_item(assigns) do
    ~H"""
    <div class="mx-auto flex h-full w-full max-w-sm flex-col overflow-hidden rounded-lg border border-dark/10 bg-light">
      <div class="relative h-56 bg-dark/5">
        <%= if @item.picture do %>
          <img
            src={LockerItems.url({@item.picture, @item}, :original, signed: true)}
            alt={@item.name}
            class={[
              "h-full w-full object-cover",
              !@item.stored && "grayscale opacity-60"
            ]}
          />
        <% else %>
          <div class="flex h-full items-center justify-center text-dark/40">
            <.icon name="hero-photo" class="h-10 w-10" />
          </div>
        <% end %>
      </div>

      <div class="flex flex-1 flex-col gap-2.5 p-3">
        <div class="flex items-start justify-between gap-3">
          <h3 class="text-xl font-semibold leading-tight text-dark">
            {@item.name}
          </h3>

          <span class={status_class(@item.stored)}>
            <.icon
              name={
                if @item.stored, do: "hero-archive-box-arrow-down", else: "hero-archive-box-x-mark"
              }
              class="h-3.5 w-3.5"
            />
            {if @item.stored, do: gettext("Stored"), else: gettext("Withdrawn")}
          </span>
        </div>

        <p class="min-h-12 line-clamp-2 text-base text-dark/60">
          {@item.description}
        </p>

        <div class="mt-auto flex items-end justify-between pt-1">
          <p class="text-xs text-dark/60">
            {format_timestamp(@item)}
          </p>

          <.backoffice_button
            :if={@item.stored}
            phx-click="withdraw-locker-item"
            phx-value-item={@item.id}
            class="py-1! px-3! text-xs"
          >
            {gettext("Withdraw")}
          </.backoffice_button>
        </div>
      </div>
    </div>
    """
  end

  defp status_class(true) do
    "inline-flex items-center gap-1 rounded-full bg-success-700/10 px-2.5 py-1 text-xs font-semibold uppercase tracking-wide text-success-700"
  end

  defp status_class(false) do
    "inline-flex items-center gap-1 rounded-full bg-warning-700/10 px-2.5 py-1 text-xs font-semibold uppercase tracking-wide text-dark/50"
  end

  defp format_timestamp(item) do
    case item.withdrawn_at || item.inserted_at do
      %DateTime{} = dt ->
        date_label =
          if Date.compare(Date.utc_today(), DateTime.to_date(dt)) == :eq,
            do: gettext("Today"),
            else: Calendar.strftime(dt, "%d-%m-%Y")

        "#{date_label}, #{Calendar.strftime(dt, "%H:%M")}"

      _ ->
        ""
    end
  end
end
