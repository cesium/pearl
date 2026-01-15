defmodule PearlWeb.Checkout.Components.PrettyIcon do
  @moduledoc """
    Stylized icon to be used on the tickets page and info card.
  """
  use PearlWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
      <div class="w-16 h-16 flex justify-center items-center" style={"background-color: color-mix(in srgb, #{@perk.color} 35%, transparent);"}>
        <span style={"color: #{@perk.color};"}>
          <.icon name={@perk.icon} class="size-10"/>
        </span>
      </div>
    """
  end
end
