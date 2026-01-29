defmodule PearlWeb.Landing.ChallengesLive.Components.ChallengeCard do
  @moduledoc """
  Desktop challenge detail card component
  """
  use Phoenix.Component
  use PearlWeb, :html
  import PearlWeb.Components.Markdown
  alias PearlWeb.Landing.ChallengesLive.Components.PrizeBadge

  attr :challenge, :map, required: true

  def challenge_card(assigns) do
    ~H"""
    <div class="hidden xl:flex">
      <div class="bg-white rounded-3xl shadow-lg overflow-hidden w-full">
        <div class="relative h-64 bg-linear-to-br from-gray-100 via-gray-50 to-white overflow-hidden">
          <div class="absolute inset-0 bg-linear-to-br from-[#8B1538]/5 via-transparent to-gray-100">
          </div>
        </div>

        <div class="p-12">
          <h2 class="select-none text-3xl text-black md:text-4xl xl:text-4xl mb-8 leading-tight">
            {@challenge.name}
          </h2>

          <div class="mb-10">
            <h3 class="text-xl font-bold text-black mb-4">Como funciona</h3>
            <div class="text-gray-700 leading-relaxed text-base">
              <.markdown
                content={@challenge.description}
                class="[&_a]:text-[#8B1538] [&_a]:underline"
              />
            </div>
          </div>

          <div>
            <h3 class="text-xl font-bold text-black mb-5">Prémios</h3>
            <div class="space-y-4">
              <%= for cp <- @challenge.prizes do %>
                <PrizeBadge.prize_badge place={cp.place} prize_name={cp.prize.name} />
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
