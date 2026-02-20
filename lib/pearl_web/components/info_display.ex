defmodule PearlWeb.Components.InfoDisplay do
  @moduledoc """
  Display info for displaying data-
  """
  use Phoenix.Component

  use Gettext, backend: PearlWeb.Gettext

  attr :id, :string, required: true
  attr :items, :list, required: true
  attr :params, :map, required: true

  slot :item do
    attr :label, :string, required: false
    attr :field, :atom
  end

  def info_display(assigns) do
    ~H"""
    <div class="relative overflow-x-auto">
      <div class="border rounded-lg bg-light border-lightShade dark:bg-dark dark:border-darkShade overflow-x-scroll scrollbar-hide flex flex-col md:flex-row">
        <div :for={item <- @items} class="grid">
          {render_slot(@item, item)}
        </div>
      </div>
    </div>
    """
  end
end
