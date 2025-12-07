defmodule PearlWeb.Landing.Components.Footer do
  @moduledoc """
  Footer component.
  """
  use PearlWeb, :component
  import PearlWeb.Landing.Components.Socials

  alias Pearl.Event

  slot :tip, required: false

  def footer(assigns) do
    ~H"""
    <footer class="bg-[#56564D] xl:px-[3rem] md:px-[2rem] px-[1rem] pt-12 md:pt-16 pb-8 md:pb-12">
      <div class="flex flex-col gap-8 md:gap-12">
        <div class="flex flex-col md:flex-row items-center md:items-center gap-3 md:gap-4 text-center md:text-left">
          <img src="/images/enei-logo-white.svg" width={100} class="md:w-[125px]" alt="ENEI Logo" />
          <div>
            <p class="text-white text-sm md:text-base leading-snug">
              encontro nacional de estudantes de informática
            </p>
            <p class="text-white text-sm md:text-base mt-1">2026</p>
          </div>
        </div>

        <div class="flex flex-col md:flex-row gap-8 md:gap-12 justify-between items-start md:items-end">
          <div class="grid grid-cols-2 md:flex md:flex-row gap-8 md:gap-12 w-full md:w-auto">
            <div>
              <h3 class="text-white font-semibold md:text-white/50 md:font-bold mb-3 md:mb-4 text-xs md:text-sm uppercase tracking-wider">
                Descobrir
              </h3>
              <ul class="space-y-2 md:space-y-2.5 text-white/50 text-xs md:text-sm">
                <%= for link <- discover_links() do %>
                  <li>
                    <.link navigate={link.url} class="hover:text-white transition-colors">
                      {link.title}
                    </.link>
                  </li>
                <% end %>
              </ul>
            </div>

            <div>
              <h3 class="text-white font-semibold md:text-white/50 md:font-bold mb-3 md:mb-4 text-xs md:text-sm uppercase tracking-wider">
                O teu ENEI
              </h3>
              <ul class="space-y-2 md:space-y-2.5 text-white/50 text-xs md:text-sm">
                <%= for link <- your_enei_links() do %>
                  <li>
                    <.link navigate={link.url} class="hover:text-white transition-colors">
                      {link.title}
                    </.link>
                  </li>
                <% end %>
              </ul>
            </div>

            <div class="col-span-2 md:col-span-1">
              <h3 class="text-white font-semibold md:text-white/50 md:font-bold mb-3 md:mb-4 text-xs md:text-sm uppercase tracking-wider">
                Mais páginas
              </h3>
              <ul class="space-y-2 md:space-y-2.5 text-white/50 text-xs md:text-sm">
                <%= for link <- more_pages_links() do %>
                  <li>
                    <.link href={link.url} class="hover:text-white transition-colors">
                      {link.title}
                    </.link>
                  </li>
                <% end %>
              </ul>
            </div>
          </div>

          <div class="grid grid-cols-2 md:flex md:flex-row gap-8 md:gap-12 w-full md:w-auto mt-4 md:mt-0">
            <div>
              <h3 class="text-white font-semibold md:text-white/50 md:font-bold mb-3 md:mb-4 text-xs md:text-sm uppercase tracking-wider">
                Redes Sociais
              </h3>
              <div>
                <.socials />
              </div>
            </div>

            <div>
              <h3 class="text-white font-semibold md:text-white/50 md:font-bold mb-3 md:mb-4 text-xs md:text-sm uppercase tracking-wider">
                Organização
              </h3>
              <.link href="https://cesium.di.uminho.pt" class="block">
                <img
                  src="/images/cesium-logo.svg"
                  alt="CeSIUM Logo"
                  class="h-10 md:h-12 opacity-70 hover:opacity-100 transition-opacity"
                />
              </.link>
            </div>
          </div>
        </div>
      </div>
      <div
        :if={@tip != []}
        class="hidden lg:flex flex-col items-center w-full justify-center absolute bottom-0 left-0 overflow-clip pointer-events-none"
      >
        <div class="group flex flex-col items-center justify-center pointer-events-auto">
          <p class="bg-white text-black text-center p-2 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity">
            {render_slot(@tip)}
          </p>
          <img
            src={~p"/images/star-struck-void.svg"}
            class="w-32 h-32 translate-y-11 group-hover:translate-y-6 transition-transform"
          />
        </div>
      </div>
    </footer>
    """
  end

  defp discover_links do
    [
      %{title: "Página Inicial", url: "/", enabled: true},
      %{title: "Calendário", url: "/calendar", enabled: true},
      %{title: "Oradores & Patrocínios", url: "/companies", enabled: true},
      %{title: "Desafios", url: "/challenges", enabled: true},
      %{title: "Organização", url: "/organizers", enabled: true},
      %{title: "Informações & Ajuda", url: "/info", enabled: true}
    ]
    |> Enum.filter(fn x -> x.enabled end)
  end

  defp your_enei_links do
    [
      %{title: "Área Pessoal", url: "/users/log_in", enabled: true},
      %{title: "Bilhetes e inscrição", url: "/buy", enabled: true},
      %{
        title: "Survival Guide",
        url: "/docs/survival-guide.pdf",
        enabled: Event.get_feature_flag!("survival_guide_enabled")
      }
    ]
    |> Enum.filter(fn x -> x.enabled end)
  end

  defp more_pages_links do
    [
      %{title: "ENEI x CeSIUM", url: "https://cesium.di.uminho.pt", enabled: true},
      %{title: "Fórum Braga", url: "https://forum.braga.pt", enabled: true}
    ]
    |> Enum.filter(fn x -> x.enabled end)
  end
end
