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
      <div class="hero-gradient-bg" aria-hidden="true"></div>

      <div class="relative z-10 flex flex-col md:flex-row md:items-center md:justify-between w-full md:min-h-[480px] pt-32 md:pt-8">
        <div class="shrink-0 px-9 pt-8 md:w-1/2 ">
          <h1 class="text-white text-3xl font-semibold mb-4 text-balance">
            {@title}
          </h1>
          <p class="text-white/50 max-w-xl leading-relaxed">
            {@description}
          </p>
        </div>
        <div class="relative shrink-0 md:w-1/2 flex items-end justify-center md:justify-end self-end">
          <img
            src={~p"/images/prizes.png"}
            alt="Prizes"
            class="w-full md:max-w-none md:w-auto h-auto max-h-[400px] xl:max-h-[520px] object-contain object-bottom"
          />
        </div>
      </div>
    </section>
    """
  end
end
