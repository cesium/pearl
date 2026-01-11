defmodule PearlWeb.Landing.HomeLive.Components.Hero do
  @moduledoc false
  use PearlWeb, :component

  import PearlWeb.Landing.Components.{JoinUs, Socials}

  attr :event_start_date, Date, required: true
  attr :event_end_date, Date, required: true
  attr :registrations_open?, :boolean, default: false

  def hero(assigns) do
    ~H"""
    <div class="px-9 pb-9">
      <div class="relative rounded-3xl overflow-hidden h-[calc(100dvh-140px)]">
        <img
          src="/images/landing.svg"
          alt=""
          class="absolute inset-0 w-full h-full object-cover"
        />
        <.title event_start_date={@event_start_date} event_end_date={@event_end_date} />
        <button
          id="slide-hero-down"
          phx-hook="SlideHeroDown"
          class="absolute bottom-6 z-10 left-1/2 -translate-x-1/2 text-white/80 cursor-pointer select-none transition-opacity duration-300">
            Desliza para ver mais
          <div class="mt-1 text-center">
            <.icon name="hero-arrow-down" />
          </div>
        </button>
      </div>
    </div>
    """
  end

  def title(assigns) do
    ~H"""
    <div class="relative z-10 h-full flex items-center justify-end">
         <div class="max-w-3xl text-left pr-10 sm:pr-14 lg:pr-20 text-white">
           <h1 class="text-3xl sm:text-4xl lg:text-5xl font-semibold leading-tight">
             encontro nacional de estudantes de informática
           </h1>
           <p class="mt-4 text-3xl sm:text-4xl lg:text-5xl font-light opacity-90">
            {display_event_dates(@event_start_date, @event_end_date)}
           </p>
         </div>
       </div>
    """
  end
  
  def announcement_bar(assigns) do
    ~H"""
    <div class="sticky top-0 z-20 bg-white/90 backdrop-blur border-b overflow-hidden">
      <div class="px-9 py-6 h-12 flex items-center justify-between gap-8">
        <div class="ticker-viewport flex-1">
          <div id="announcement-ticker" phx-hook="Ticker" class="ticker-track">
            <span class="ticker-item text-dark-muted">
              as inscrições abrem no dia 5 de janeiro
            </span>
          </div>
        </div>
        <button class="shrink-0 flex items-center gap-2 text-primary font-medium whitespace-nowrap">
          <.icon name="hero-bell" />
          obtém um lembrete
        </button>
      </div>
    </div>
    """
  end

  defp display_event_dates(event_start_date, event_end_date) do
    "#{Timex.format!(event_start_date, "{D}")}-#{Timex.format!(event_end_date, "{D} {Mfull} {YYYY}")}"
  end

  def venue_section(assigns) do
    ~H"""
    <section class="bg-white pt-20">
      <div class="relative isolate overflow-hidden">
        <div class="w-full px-16 mb-20">
          <div class="relative z-10">
            <div>
              <h2 class="text-4xl lg:text-5xl font-semibold leading-tight text-dark w-xl pb-24">
                Este ano, o teu evento favorito está em
                <span class="relative inline-block">
                  Braga
                  <span class="absolute left-0 -bottom-1 w-full h-1 bg-primary"></span>
                </span>
              </h2>
            </div>
            <div class="relative">
              <div 
                class="left-1/2 top-0 -translate-x-1/2 -translate-y-[67%] absolute -z-10 w-[calc(189svw)] h-[calc(145svh)] bg-[radial-gradient(50%_50%_at_50%_50%,_#FFFFFF_50.48%,_rgba(255,255,255,0)_75%,_#FFFFFF_98%),radial-gradient(23.07%_57.76%_at_50%_50%,_#DC6526_65%,_#5028E1_75%,_#E9225C_100%)] opacity-20">
              </div>
              <div class="overflow-hidden">
                <img
                  src="/images/venue.svg"
                  alt="Forum Braga"
                  class="w-full h-[250px] object-cover"
                />
              </div>
              <div class="absolute right-0 -top-42 w-[46%] bg-white p-12">
                <div class="text-gray-700 leading-relaxed space-y-4 text-base">
                  <p>
                    O Encontro Nacional de Estudantes de Informática é um evento anual
                    repleto de palestras, workshops, tertúlias, e muitas mais atividades.
                    É a tua deixa para conhecer pessoas, empresas, e (melhor de tudo)
                    ganhar prémios!
                  </p>
                  <p class="font-medium text-gray-900">
                    Sejas estudante, professor, profissional ou simplesmente interessado
                    em informática, o ENEI é para ti.
                  </p>
                </div>
              </div>        
            </div>
          </div>
          <div class="mt-6 flex items-center justify-center gap-3 text-gray-600">
            <.icon name="hero-map-pin" class="w-5 h-5" />
            <span class="text-sm">
              Forum Braga · Av. Dr. Francisco Pires Gonçalves, 4715-558 Braga
            </span>
          </div>
        </div>
      </div>
    </section>
    """
  end
end