defmodule PearlWeb.Components.ScannerTabs do
  @moduledoc false
  use PearlWeb, :component

  attr :active, :atom,
    required: true,
    doc: "Which tab is active (:badges, :tickets, :redeems, :meals)"

  attr :current_user, :map,
    default: nil,
    doc: "Current user"

  import PearlWeb.Components.{EnsurePermissions, Tabs}

  def scanner_tabs(assigns) do
    ~H"""
    <.tabs class="sm:hidden mb-4">
      <.link patch={~p"/dashboard/scanner"} class="w-full">
        <.tab class="gap-2" active={@active == :badges}>
          <.icon name="fa-award-solid" />
        </.tab>
      </.link>

      <.ensure_permissions
        :if={@current_user}
        user={@current_user}
        permissions={%{"attendees" => ["show"]}}
      >
        <.link patch={~p"/dashboard/scanner/tickets"} class="w-full">
          <.tab class="gap-2" active={@active == :tickets}>
            <.icon name="fa-ticket-solid" />
          </.tab>
        </.link>
      </.ensure_permissions>

      <.link patch={~p"/dashboard/scanner/redeems"} class="w-full">
        <.tab class="gap-2" active={@active == :redeems}>
          <.icon name="fa-dolly-solid" />
        </.tab>
      </.link>

      <.ensure_permissions
        :if={@current_user}
        user={@current_user}
        permissions={%{"attendees" => ["show"]}}
      >
        <.link patch={~p"/dashboard/scanner/meals"} class="w-full">
          <.tab class="gap-2" active={@active == :meals}>
            <.icon name="fa-utensils-solid" />
          </.tab>
        </.link>
      </.ensure_permissions>
    </.tabs>
    """
  end
end
