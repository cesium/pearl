defmodule PearlWeb.Backoffice.AttendeeLive.Index do
  alias Pearl.Accounts
  use PearlWeb, :backoffice_view

  import PearlWeb.Components.Table
  import PearlWeb.Components.TableSearch

  on_mount {PearlWeb.StaffRoles,
            index: %{"attendees" => ["show"]}, edit: %{"attendees" => ["edit"]}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    case Accounts.list_attendees(params) do
      {:ok, {attendees, meta}} ->
        {:noreply,
         socket
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> assign(:current_page, :attendees)
         |> stream(:attendees, attendees, reset: true)}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
