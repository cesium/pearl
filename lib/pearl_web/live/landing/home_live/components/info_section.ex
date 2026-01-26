defmodule PearlWeb.Landing.HomeLive.Components.InfoSection do
  @moduledoc false
  use PearlWeb, :component

  def announcement_bar(assigns) do
    ~H"""
    <div class="sticky top-0 z-20 bg-light/90 backdrop-blur border-b overflow-hidden">
      <div class="px-9 py-6 h-17.5 flex items-center justify-between gap-8">
        <div class="ticker-viewport flex-1 mx-auto">
          <div id="announcement-ticker" phx-hook="Ticker" class="ticker-track">
            <span class="ticker-item text-dark/50">
              <%= if @registrations_open? do %>
                {gettext("as inscrições já estão abertas!")}
              <% else %>
                {gettext("as inscrições abrem no dia 5 de janeiro")}
              <% end %>
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def info_section(assigns) do
    ~H"""
    <div class="grid grid-cols-1 lg:grid-cols-[1fr_1fr] gap-12">
      <section class="bg-light pt-20">
        <div class="relative isolate overflow-hidden">
          <div class="w-[calc(100vw)] mx-auto px-6.5 md:px-16 mb-20">
            <div class="relative z-10">
              <div>
                <h2 class="text-3xl lg:text-4xl xl:text-5xl font-semibold leading-tight text-dark w-sm xl:w-xl pb-10">
                  {gettext("Este ano, o teu evento favorito está em")}
                  <span class="relative inline-block">
                    {gettext("Braga")}
                    <span class="absolute left-0 -bottom-1 w-full h-1 bg-primary"></span>
                  </span>
                </h2>
              </div>
              <div class="relative">
                <div class="relative ">
                  <div class="left-1/2 top-0 -translate-x-1/2 -translate-y-[67%] absolute -z-10 w-[210%] h-[470%] bg-[radial-gradient(50%_50%_at_50%_50%,_#FFFFFF_50.48%,_rgba(255,255,255,0)_75%,_#FFFFFF_98%),radial-gradient(23.07%_57.76%_at_50%_50%,_#DC6526_65%,_#5028E1_75%,_#E9225C_100%)] opacity-20 2xl:bg-none">
                  </div>
                  <div class="relative hover:scale-101 hover:shadow-2xl hover:translate-y-1 transition-all duration-300 h-46 lg:h-[190px]">
                    <img
                      src="/images/forum-braga.svg"
                      alt="Forum Braga"
                      class="w-full h-full object-cover sm:object-[20%_70%]"
                    />
                  </div>
                </div>
                <div class="relative isolate overflow-visible">
                  <div class="absolute left-1/2 -translate-x-1/2 translate-y-2 md:translate-y-10 lg:left-auto lg:translate-x-0 lg:right-0 -top-13 md:-top-30 lg:-top-100 w-[84%] lg:w-[46%] bg-light p-5 lg:p-6 lg:pr-16">
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
