defmodule PearlWeb.Landing.Components.Footer do
  @moduledoc """
  Footer component.
  """
  use PearlWeb, :component
  import PearlWeb.Landing.Components.Socials

  alias Pearl.Event

  slot :tip, required: false

  def footer(assigns) do
    assigns =
      assign(assigns,
        landing_pages: PearlWeb.Config.landing_pages(),
        your_enei_links: your_enei_links(),
        more_pages_links: more_pages_links()
      )

    ~H"""
    <footer class="bg-dark-muted px-8 pt-8 pb-12 md:px-12.5 md:pt-12.5 md:pb-16">
      <div class="flex flex-col gap-8 md:gap-12">
        <div class="grid grid-cols-[auto_1fr] gap-x-3.5 items-start">
          <img src="/images/enei-logo-white.svg" width={75} alt="ENEI Logo" class="row-span-2" />
          <p class="text-white text-sm md:text-base self-end">
            encontro nacional de estudantes de informática
          </p>
          <p class="text-light/50 col-start-2">2026</p>
        </div>

        <div class="flex flex-col md:flex-row gap-8 md:gap-12 justify-between items-start md:items-end">
          <div class="grid grid-cols-2 md:flex md:flex-row gap-8 md:gap-12 w-full md:w-auto">
            <div :if={@landing_pages != []}>
              <h3 class="text-white font-semibold md:text-white/50 md:font-bold mb-3 md:mb-4 text-xs md:text-sm uppercase tracking-wider">
                Descobrir
              </h3>
              <ul class="space-y-2 md:space-y-2.5 text-white/50 text-xs md:text-sm">
                <%= for link <- @landing_pages do %>
                  <li>
                    <.link navigate={link.url} class="hover:text-white transition-colors">
                      {link.title}
                    </.link>
                  </li>
                <% end %>
              </ul>
            </div>

            <div :if={@your_enei_links != []}>
              <h3 class="text-white font-semibold md:text-white/50 md:font-bold mb-3 md:mb-4 text-xs md:text-sm uppercase tracking-wider">
                O teu ENEI
              </h3>
              <ul class="space-y-2 md:space-y-2.5 text-white/50 text-xs md:text-sm">
                <%= for link <- @your_enei_links do %>
                  <li>
                    <.link navigate={link.url} class="hover:text-white transition-colors">
                      {link.title}
                    </.link>
                  </li>
                <% end %>
              </ul>
            </div>

            <div :if={@more_pages_links != []} class="col-span-2 md:col-span-1">
              <h3 class="text-white font-semibold md:text-white/50 md:font-bold mb-3 md:mb-4 text-xs md:text-sm uppercase tracking-wider">
                Mais páginas
              </h3>
              <ul class="space-y-2 md:space-y-2.5 text-white/50 text-xs md:text-sm">
                <%= for link <- @more_pages_links do %>
                  <li>
                    <.link href={link.url} target="_blank" class="hover:text-white transition-colors">
                      {link.title}
                    </.link>
                  </li>
                <% end %>
              </ul>
            </div>
          </div>

          <div class="flex gap-12.5">
            <div class="space-y-3">
              <h3 class="text-white/50 font-bold text-xs md:text-sm uppercase">
                Redes Sociais
              </h3>
              <div>
                <.socials />
              </div>
            </div>

            <div class="space-y-2">
              <h3 class="text-white/50 font-bold text-xs md:text-sm uppercase">
                Organização
              </h3>
              <.link href="https://cesium.di.uminho.pt" target="_blank" class="block">
                <img
                  src="/images/cesium-logo.svg"
                  alt="CeSIUM Logo"
                  class="h-8.5 opacity-70 hover:opacity-100 transition-opacity"
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

  defp your_enei_links do
    [
      %{title: "Área Pessoal", url: "/users/log_in", enabled: true},
      %{title: "Bilhetes e inscrição", url: "/tickets", enabled: false},
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
      %{title: "Forum Braga", url: "https://www.forumbraga.com/", enabled: true}
    ]
    |> Enum.filter(fn x -> x.enabled end)
  end
end
