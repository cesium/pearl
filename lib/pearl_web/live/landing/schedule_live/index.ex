defmodule PearlWeb.Landing.ScheduleLive.Index do
  use PearlWeb, :landing_view

  alias Pearl.Event

  on_mount {PearlWeb.VerifyFeatureFlag, "schedule_enabled"}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current_page, :schedule)
     |> assign(:event_start_date, Event.get_event_start_date())
     |> assign(:event_end_date, Event.get_event_end_date())
     |> assign(:registrations_open?, Event.registrations_open?())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> assign(:params, params)}
  end

  @impl true
  def handle_info({:update_flash, {flash_type, msg}}, socket) do
    {:noreply, put_flash(socket, flash_type, msg)}
  end
end
