defmodule PearlWeb.Landing.ChallengesLive.Components.MobileDetail do
  @moduledoc """
  Mobile challenge detail view with back navigation
  """
  use Phoenix.Component
  use PearlWeb, :html
  import PearlWeb.Components.Markdown
  alias PearlWeb.Landing.ChallengesLive.Components.PrizeBadge

  attr :challenge, :map, required: true

  def mobile_detail(assigns) do
    ~H"""
    <div>
      <button
        phx-click="mobile_back"
        class="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors mb-6"
      >
        <.icon name="hero-chevron-left" class="w-6 h-6" />
        <span class="font-medium">{@challenge.name}</span>
      </button>

      <div class="bg-white rounded-3xl shadow-lg overflow-hidden">
        <div class="relative h-48 bg-linear-to-br from-gray-100 via-gray-50 to-white">
          <div class="absolute inset-0 bg-linear-to-br from-[#8B1538]/5 via-transparent to-gray-100">
          </div>
        </div>

        <div class="p-8">
          <div class="mb-6">
            <h3 class="text-lg font-bold text-black mb-3">Como funciona</h3>
            <div class="text-gray-700 leading-relaxed text-sm">
              <.markdown content={@challenge.description} class="[&_a]:text-primary [&_a]:underline" />
            </div>
          </div>

          <div>
            <h3 class="text-lg font-bold text-black mb-4">Prémios</h3>
            <div class="space-y-3">
              <%= for cp <- @challenge.prizes do %>
                <PrizeBadge.prize_badge place={cp.place} prize_name={cp.prize.name} size="small" />
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
