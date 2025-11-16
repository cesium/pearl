defmodule PearlWeb.Backoffice.ProductLive.Index do
  use PearlWeb, :backoffice_view

  alias Pearl.Store
  alias Pearl.Store.Product

  import PearlWeb.Components.Table
  import PearlWeb.Components.TableSearch

  on_mount {PearlWeb.StaffRoles,
            index: %{"products" => ["show"]},
            new: %{"products" => ["edit"]},
            edit: %{"products" => ["edit"]},
            show: %{"products" => ["show"]}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    case Store.list_products(params) do
      {:ok, {products, meta}} ->
        {:noreply,
         socket
         |> assign(:current_page, :store)
         |> assign(:meta, meta)
         |> assign(:params, params)
         |> stream(:products, products, reset: true)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Store.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Store.get_product!(id)
    {:ok, _} = Store.delete_product(product)

    {:noreply, stream_delete(socket, :products, product)}
  end
end
