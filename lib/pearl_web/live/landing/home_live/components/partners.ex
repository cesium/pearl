defmodule PearlWeb.Landing.HomeLive.Components.Partners do
  @moduledoc false
  use PearlWeb, :component

  def partners(assigns) do
    assigns = assign(assigns, partners: event_partners())

    ~H"""
    <div :if={@partners != []} class="flex items-center justify-center flex-col pt-14.5">
      <div class="flex flex-col gap-5 items-center text-black px-4 md:px-8">
        <h2 class="flex font-semibold justify-center text-center text-2xl md:text-3xl max-w-full md:max-w-[580px]">
          {gettext("Parceiros que fizeram isto possível")}
        </h2>
        <p class="text-center max-w-full md:max-w-3xl lg:max-w-5xl">
          Os nossos parceiros são entidades que colaboram connosco para tornar o ENEI possível. Através do seu apoio e contributo, ajudam a enriquecer a experiência do evento e a criar mais valor para todos os participantes.
        </p>
      </div>
      <div class="my-10 flex flex-wrap items-center justify-center md:gap-10">
        <div
          :for={partner <- @partners}
          class="m-auto w-40 select-none opacity-100 hover:opacity-80 hover:scale-105 duration-500 transition-all"
        >
          <.link href={partner.url} target="_blank" rel="noreferrer">
            <img
              src={"/images/partners/#{partner.logo}"}
              class={["w-full h-40", partner.style]}
              alt={partner.name}
            />
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp event_partners do
    [
      # %{
      #   name: "UMinho School of Engineering",
      #   url: "https://www.eng.uminho.pt",
      #   logo: "eeum.svg",
      #   style: "scale-95"
      # },
      # %{
      #   name: "IPDJ",
      #   url: "https://ipdj.gov.pt",
      #   logo: "ipdj.svg",
      #   style: "scale-55"
      # },
      # %{
      #   name: "Startup Braga",
      #   url: "https://www.startupbraga.com/",
      #   logo: "startupbraga.svg",
      #   style: ""
      # },
      # %{
      #   name: "Braga",
      #   url: "https://www.cm-braga.pt/pt",
      #   logo: "braga.svg",
      #   style: ""
      # },
      # %{
      #   name: "Lighthouse studios",
      #   url: "https://lighthousestudios.pt/",
      #   logo: "lighthouse.webp",
      #   style: "scale-115 object-contain"
      # },
      # %{
      #   name: "Mauser",
      #   url: "https://mauser.pt/",
      #   logo: "mauser.svg",
      #   style: ""
      # }
    ]
  end
end
