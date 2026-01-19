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
          class="absolute bottom-6 z-10 left-1/2 -translate-x-1/2 text-light/80 cursor-pointer select-none transition-opacity duration-300"
        >
          {gettext("Desliza para ver mais")}
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
      <div class="max-w-3xl text-left pl-10 pr-10 sm:pr-14 lg:pr-20 text-light">
        <h1 class="text-3xl sm:text-4xl lg:text-5xl font-semibold leading-tight">
          {gettext("encontro nacional de estudantes de informática")}
        </h1>
        <p class="mt-4 text-3xl sm:text-4xl lg:text-5xl text-right md:text-left font-light opacity-90">
          {gettext("%{dates}", dates: display_event_dates(@event_start_date, @event_end_date))}
        </p>
      </div>
    </div>
    """
  end

  def announcement_bar(assigns) do
    ~H"""
    <div class="sticky top-0 z-20 bg-light/90 backdrop-blur border-b overflow-hidden">
      <div class="px-9 py-6 h-12 flex items-center justify-between gap-8">
        <div class="ticker-viewport flex-1">
          <div id="announcement-ticker" phx-hook="Ticker" class="ticker-track">
            <span class="ticker-item text-dark-muted">
              {gettext("as inscrições abrem no dia 5 de janeiro")}
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp display_event_dates(event_start_date, event_end_date) do
    "#{Timex.format!(event_start_date, "{D}")}-#{Timex.format!(event_end_date, "{D} {Mfull} {YYYY}")}"
  end

  def info_section(assigns) do
    ~H"""
    <div class="grid grid-cols-1 lg:grid-cols-[1fr_1fr] gap-12">
      <section class="bg-light pt-20">
        <div class="relative isolate overflow-hidden">
          <div class="w-[calc(100vw)] mx-auto px-9 md:px-16 mb-20">
            <div class="relative z-10">
              <div>
                <h2 class="text-3xl lg:text-4xl xl:text-5xl font-semibold leading-tight text-dark w-sm lg:w-lg xl:w-xl pb-10">
                  {gettext("Este ano, o teu evento favorito está em")}
                  <span class="relative inline-block">
                    {gettext("Braga")}
                    <span class="absolute left-0 -bottom-1 w-full h-1 bg-primary"></span>
                  </span>
                </h2>
              </div>
              <div class="relative">
                <div class="relative ">
                  <div class="left-1/2 top-0 -translate-x-1/2 -translate-y-[67%] absolute -z-10 w-[210%] h-[470%] bg-[radial-gradient(50%_50%_at_50%_50%,_#FFFFFF_50.48%,_rgba(255,255,255,0)_75%,_#FFFFFF_98%),radial-gradient(23.07%_57.76%_at_50%_50%,_#DC6526_65%,_#5028E1_75%,_#E9225C_100%)] opacity-20">
                  </div>
                  <img
                    src="/images/venue.svg"
                    alt="Forum Braga"
                    class="w-full aspect-[16/9] lg:h-[250px] object-cover"
                  />
                </div>
                <div class="relative">
                  <div class="absolute left-1/2 -translate-x-1/2 lg:left-auto lg:translate-x-0 lg:right-0 -top-13 md:-top-30 lg:-top-100 w-[75%] lg:w-[46%] bg-light p-5 lg:p-6 lg:pr-16">
                    <div class="text-dark leading-relaxed space-y-4">
                      <p>
                        {gettext("O Encontro Nacional de Estudantes de Informática é um evento anual
                                repleto de palestras, workshops, tertúlias, e muitas mais atividades.
                                É a tua deixa para conhecer pessoas, empresas, e (melhor de tudo)
                                ganhar prémios!")}
                      </p>
                      <p class="font-medium">
                        {gettext("Sejas estudante, professor, profissional ou simplesmente interessado
                                em informática, o ENEI é para ti.")}
                      </p>
                    </div>
                  </div>
                  <div class="pt-110 sm:pt-52 md:pt-28 lg:pt-12 flex flex-col lg:flex-row items-center justify-center gap-3 text-dark-muted text-center">
                    <.icon name="hero-map-pin" class="w-5 h-5" />
                    <span>
                      {gettext("Forum Braga | Av. Dr. Francisco Pires Gonçalves, 4715-558 Braga")}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end
end
