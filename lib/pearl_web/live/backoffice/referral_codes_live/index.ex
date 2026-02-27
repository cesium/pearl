defmodule PearlWeb.Backoffice.ReferralsLive.Index do
  use PearlWeb, :backoffice_view

  import PearlWeb.Components.{Table, TableSearch, Modal}

  alias Pearl.Referrals.Referral
  alias Pearl.Referrals

  on_mount {PearlWeb.StaffRoles,
            show: %{"referrals" => ["show"]},
            edit: %{"referrals" => ["edit"]}}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    case Referrals.list_referrals(params) do
      {:ok, {referrals, meta}} ->
        {:noreply,
        socket
        |> assign(:current_page, :referrals)
        |> assign(:meta, meta)
        |> assign(:params, params)
        |> stream(:referrals, referrals, reset: true)
        |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Referral Codes")
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Referral")
    |> assign(:referral, Referrals.get_referral(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Referral")
    |> assign(:referral, %Referral{})
  end

  defp apply_action(socket, :users, %{"id" => id}) do
    socket
    |> assign(:page_title, "Listing Attendees")
    |> assign(:referral, Referrals.get_referral(id))
  end

    def handle_event("delete", %{"id" => id}, socket) do
    referral = Referrals.get_referral(id)
    {:ok, _} = Referrals.delete_referral(referral)
    {:noreply, stream_delete(socket, :referrals, referral)}
  end

end
