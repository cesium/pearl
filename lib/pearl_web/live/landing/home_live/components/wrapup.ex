defmodule PearlWeb.Landing.HomeLive.Components.Wrapup do
  @moduledoc false
  use PearlWeb, :component

  def link_wrapup(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-11.5 text-dark py-22.5">
      <div class="text-center space-y-2.5 max-w-3xl">
        <h2 class="font-semibold text-3xl">{gettext("Temos encontro marcado?")}</h2>
        <p>
          {gettext(
            "Os bilhetes estarão disponíveis a partir do dia 5 de janeiro de 2026. Se já estiveres convencido, podes-te pré-inscrever sem compromisso. Caso contrário, podes explorar mais."
          )}
        </p>
      </div>

      <div class="flex flex-col sm:flex-row justify-center gap-2.5 w-full max-w-5xl px-4">
        <div class="flex flex-col justify-between text-center space-y-2.5 w-full md:w-92 h-64 sm:h-auto px-6 md:px-11 py-5 border-t-2 border-dark/10">
          <h3 class="font-medium">{gettext("Precias de ajuda?")}</h3>
          <p>
            {gettext(
              "Se tiveres perguntas, nós teremos respostas. Visita a página de ajuda para veres FAQs, os nossos contactos e mais."
            )}
          </p>
          <div class="flex justify-center">
            <.link
              navigate="/team"
              class="text-primary inline-flex items-center gap-2 transition-all duration-300 hover:gap-4 hover:font-semibold group"
            >
              <.icon name="hero-arrow-right" class="shrink-0" />
              {gettext("ir para Informação & Ajuda")}
            </.link>
          </div>
        </div>

        <div class="flex flex-col justify-between text-center w-full md:w-92 h-64 sm:h-auto px-6 md:px-11 py-5 border-t-2 border-primary">
          <h3 class="text-xl font-bold text-primary">
            {gettext("Os bilhetes já estão disponíveis! Não percas a oportunidade e inscreve-te")}
          </h3>
          <div class="flex justify-center">
            <.link
              navigate="/team"
              class="text-primary inline-flex items-center gap-2 transition-all duration-300 hover:gap-4 hover:font-semibold group"
            >
              <.icon name="hero-arrow-right" class="shrink-0" />
              {gettext("compra o teu bilhete")}
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
