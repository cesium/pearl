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
    <section class="relative w-full bg-black overflow-hidden -mt-32">
      <div class="relative z-10 flex flex-col lg:flex-row lg:items-center lg:justify-between w-full lg:min-h-[480px] pt-32 lg:pt-8">
        <div class="shrink-0 px-7.5 lg:px-12.5 pt-8 lg:w-1/2">
          <h1 class="text-white text-3xl font-semibold mb-4 text-balance">
            {@title}
          </h1>
          <p class="text-white/50 max-w-xl leading-relaxed">
            {@description}
          </p>
        </div>
        <div class="relative shrink-0 lg:w-1/2 flex items-end justify-center lg:justify-end lg:self-end">
          <img
            src={~p"/images/prizes.webp"}
            alt="Prizes"
            class="h-full w-auto lg:max-w-none object-contain object-bottom"
          />
        </div>
      </div>
    </section>
    """
  end
end
