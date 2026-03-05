defmodule PearlWeb.Landing.ProfileSettingsLive.Index do
  use PearlWeb, :landing_view

  @impl true
  def mount(params, _session, socket) do
    referral_code = Map.get(params, "referral_code", "")

    {:ok,
     socket
     |> assign(:current_page, :profile)
     |> assign(:page_title, "Profile Settings")
     |> assign(:referral_code, referral_code)}
  end

  @impl true
  def handle_info({:update_current_user, user}, socket) do
    {:noreply, assign(socket, :current_user, user)}
  end

  @impl true
  def handle_info({:update_flash, {flash_type, msg}}, socket) do
    {:noreply, put_flash(socket, flash_type, msg)}
  end
end
