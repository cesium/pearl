defmodule PearlWeb.Backoffice.DiscountCodesLive.Index do
  use PearlWeb, :backoffice_view

  import PearlWeb.Components.Table

  alias Pearl.DiscountCodes
  alias Pearl.DiscountCodes.DiscountCode

  on_mount {PearlWeb.StaffRoles,
            index: %{"discount_codes" => ["show"]},
            new: %{"discount_codes" => ["edit"]},
            edit: %{"discount_codes" => ["edit"]}
          }

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    case DiscountCodes.list_discount_codes(params) do
      {:ok, {discount_codes, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :discount_codes)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:discount_codes, discount_codes, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Discount Codes")
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Discount Code")
    |> assign(:discount_code, %DiscountCode{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Discount Code")
    |> assign(:discount_code, DiscountCodes.get_discount_code!(id))
  end

  def handle_event("delete", %{"id" => id}, socket) do
    discount_code = DiscountCodes.get_discount_code!(id)
    {:ok, _} = DiscountCodes.delete_discount_code(discount_code)

    {:noreply, stream_delete(socket, :discount_codes, discount_code)}
  end
end
