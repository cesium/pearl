defmodule PearlWeb.Landing.ChallengesLive.Components.Hero do
  @moduledoc """
  Hero section with background gradient and prizes image
  """
  use Phoenix.Component
  use PearlWeb, :html

  attr :title, :string, required: true
  attr :description, :string, required: true

  def hero(assigns) do
    ~H"""
    <div class="relative -mt-32">
      <div class="absolute top-0 left-0 right-0 h-[600px] z-0 overflow-hidden">
        <div class="absolute inset-0 bg-black"></div>

        <div
          class="absolute right-0 top-0 bottom-0 w-[1000px]"
          style="background: radial-gradient(ellipse at 80% 50%, rgba(127, 29, 29, 0.5) 0%, rgba(127, 29, 29, 0.35) 30%, rgba(180, 83, 9, 0.25) 50%, transparent 75%);"
        >
        </div>

        <div class="absolute -right-5 bottom-0 flex items-end">
          <img
            src={~p"/images/prizes.svg"}
            alt="Prizes"
            class="h-[520px] md:h-[580px] w-auto object-contain"
          />
        </div>
      </div>

      <div class="relative z-10 w-full pt-64">
        <div class="w-full mx-auto px-6.5 md:px-16 mb-20">
          <h1 class="text-white text-4xl font-semibold mb-6">
            {@title}
          </h1>

          <p class="text-white/50 text-lg max-w-xl">
            {@description}
          </p>
        </div>
      </div>
    </div>
    """
  end
end
