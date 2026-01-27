defmodule PearlWeb.Landing.HomeLive.Components.Hero do
  @moduledoc false
  use PearlWeb, :component

  attr :event_start_date, Date, required: true
  attr :event_end_date, Date, required: true

  def hero(assigns) do
    ~H"""
    <div class="px-5 pb-5 sm:px-6 sm:pb-6">
      <div class="relative rounded-3xl sm:rounded-4xl overflow-hidden h-[calc(100dvh-116px)]  xl:h-[calc(100dvh-132px)]">
        <img
          src="/images/landing.webp"
          alt=""
          class="absolute inset-0 w-full h-full object-cover"
        />
        <div class="relative z-10 h-full flex items-center justify-end">
          <div class="max-w-3xl text-left pl-10 pr-10 sm:pr-14 lg:pr-20 text-light">
            <h1 class="text-3xl sm:text-4xl lg:text-5xl font-semibold leading-tight">
              {gettext("encontro nacional de estudantes de informática")}
            </h1>
            <p class="mt-4 text-3xl sm:text-4xl lg:text-5xl text-right md:text-left font-light opacity-90">
              {Timex.format!(@event_start_date, "{D}")}-{Timex.lformat!(
                @event_end_date,
                "{D} {Mfull} {YYYY}",
                "pt"
              )}
            </p>
          </div>
        </div>
        <a
          href="#info-section"
          class="absolute bottom-6 z-10 left-1/2 -translate-x-1/2 text-light/80 cursor-pointer select-none transition-opacity duration-300"
        >
          {gettext("Desliza para ver mais")}
          <div class="mt-1 text-center">
            <.icon name="hero-arrow-down" />
          </div>
        </a>
      </div>
    </div>
    """
  end
end
