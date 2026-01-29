defmodule PearlWeb.Landing.ChallengesLive.Components.PrizeBadge do
  @moduledoc """
  Badge component for displaying challenge prizes with medal-style design
  """
  use Phoenix.Component

  attr :place, :integer, required: true
  attr :prize_name, :string, required: true
  attr :size, :string, default: "default", values: ~w(default small)

  def prize_badge(assigns) do
    ~H"""
    <div class="flex items-center gap-4">
      <div class="relative shrink-0">
        <div class={[
          "rounded-full flex items-center justify-center text-white font-bold shadow-md",
          badge_color(@place),
          if(@size == "small", do: "w-10 h-10 text-sm", else: "w-12 h-12 text-lg")
        ]}>
          {@place}
        </div>
        <div
          class={[
            "absolute left-1/2 -translate-x-1/2",
            ribbon_color(@place),
            if(@size == "small", do: "-bottom-0.5 w-5 h-2", else: "-bottom-1 w-6 h-3")
          ]}
          style="clip-path: polygon(0 0, 50% 100%, 100% 0, 100% 70%, 50% 50%, 0 70%);"
        >
        </div>
      </div>
      <p class={[
        "text-gray-900 font-medium",
        if(@size == "small", do: "text-sm", else: "text-base")
      ]}>
        {@prize_name}
      </p>
    </div>
    """
  end

  defp badge_color(1), do: "bg-gradient-to-br from-[#FFD700] to-[#D4AF37]"
  defp badge_color(2), do: "bg-gradient-to-br from-[#E0E0E0] to-[#C0C0C0]"
  defp badge_color(_), do: "bg-gradient-to-br from-[#E6A57E] to-[#CD7F32]"

  defp ribbon_color(1), do: "bg-[#D4AF37]"
  defp ribbon_color(2), do: "bg-[#C0C0C0]"
  defp ribbon_color(_), do: "bg-[#CD7F32]"
end
