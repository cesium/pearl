defmodule PearlWeb.App.VaultLive.Components.Item do
  @moduledoc """
  Vault item component.
  """
  use PearlWeb, :component

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :image, :string, required: true
  attr :data, :map, required: true
  attr :redeemed, :boolean, required: true

  def item(assigns) do
    ~H"""
    <li id={@id} class={"flex flex-row items-center py-5 #{if @redeemed do "opacity-50" end}"}>
      <figure class={["w-26 h-26 rounded-xl shrink-0", product_gradient_class(@data.id)]}>
        <%= if @image do %>
          <img class="w-full p-4" src={@image} />
        <% end %>
      </figure>
      <div class="px-4">
        <h1 class="uppercase font-semibold text-2xl">
          {@name}
        </h1>
        <p :if={!@redeemed} class="text-light/80">
          {gettext("Dirija-se à acreditação para coletar o teu item!")}
        </p>
        <p :if={@redeemed} class="flex flex-row justify-center items-center">
          <.icon name="hero-check" class="w-5 h-5 mr-1" />
          {gettext("Adquiriste este item!")}
        </p>
      </div>
    </li>
    """
  end
end
