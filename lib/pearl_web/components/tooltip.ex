defmodule PearlWeb.Components.Tooltip do
  @moduledoc """
  Tooltip component module.
  """
  use Phoenix.Component

  attr :text, :string, required: true
  attr :position, :string, default: "top", values: ["top", "bottom", "left", "right"]
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def tooltip(assigns) do
    ~H"""
    <div class={["relative inline-block group", @class]}>
      {render_slot(@inner_block)}
      <div class={[
        "absolute z-50 px-3 py-2 text-sm font-medium text-white bg-gray-900 rounded-lg shadow-sm opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none w-max max-w-[200px] sm:max-w-xs wrap-break-word",
        position_class(@position)
      ]}>
        {@text}
        <div class={arrow_class(@position)}></div>
      </div>
    </div>
    """
  end

  defp position_class("top"), do: "bottom-full left-1/2 -translate-x-1/2 mb-2"
  defp position_class("bottom"), do: "top-full left-1/2 -translate-x-1/2 mt-2"
  defp position_class("left"), do: "right-full top-1/2 -translate-y-1/2 mr-2"
  defp position_class("right"), do: "left-full top-1/2 -translate-y-1/2 ml-2"

  defp arrow_class("top"),
    do:
      "absolute top-full left-1/2 -translate-x-1/2 border-4 border-transparent border-t-gray-900"

  defp arrow_class("bottom"),
    do:
      "absolute bottom-full left-1/2 -translate-x-1/2 border-4 border-transparent border-b-gray-900"

  defp arrow_class("left"),
    do:
      "absolute left-full top-1/2 -translate-y-1/2 border-4 border-transparent border-l-gray-900"

  defp arrow_class("right"),
    do:
      "absolute right-full top-1/2 -translate-y-1/2 border-4 border-transparent border-r-gray-900"
end
