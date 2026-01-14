defmodule PearlWeb.Landing.HomeLive.Components.Sponsors do
  @moduledoc false
  use PearlWeb, :component

  alias Pearl.Uploaders

  def sponsors(assigns) do
    ~H"""
    <div class="flex items-center justify-center flex-col py-14.5">
      <div class="flex flex-col gap-5 items-center text-black px-4 md:px-8">
        <h2 class="flex font-semibold justify-center text-center text-2xl md:text-3xl max-w-full md:max-w-[580px]">
          {gettext("Um elenco de empresas que abre portas e janelas")}
        </h2>
        <p class="text-center max-w-full md:max-w-3xl lg:max-w-5xl">
          As empresas incríveis que nos patrocinam são quem possibilita o ENEI. Durante todo o evento, vais poder encontrá-las e falar com os seus representantes para as conheceres melhor.
        </p>
      </div>
      <div class="flex flex-col gap-10 pt-10">
        <%= for tier <- @tiers do %>
          <.sponsor_segment tier={tier} sponsors={tier.companies} />
        <% end %>
      </div>
    </div>
    """
  end

  def sponsor_segment(assigns) do
    ~H"""
    <div class="flex  flex-col justify-center">
      <div class="flex w-full flex-row items-start justify-center">
        <p
          class="uppercase self-stretch min-w-36 flex flex-col font-light text-xl border-r-2"
          style={"color: #{@tier.color}; border-color: color-mix(in srgb, #{@tier.color}, transparent 67%);"}
        >
          <span class="font-semibold">{@tier.name}</span> sponsors
        </p>
        <div class="grid grid-cols-2 xs:grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 w-full gap-x-8 gap-y-12 md:gap-x-12.5 md:gap-y-16 items-start justify-items-center px-4">
          <%= for sponsor <- @sponsors |> Enum.shuffle() do %>
            <.link
              href={sponsor.url}
              target="_blank"
              class="opacity-80 hover:opacity-100 hover:scale-105 duration-500 transition-all mx-auto"
            >
              <%= if sponsor.logo do %>
                <div class="w-30 h-16 sm:w-40 sm:h-16 flex items-center justify-center">
                  <img
                    class="max-w-full max-h-full object-contain"
                    src={Uploaders.Company.url({sponsor.logo, sponsor}, :original, signed: true)}
                  />
                </div>
              <% else %>
                <p class="text-2xl text-center p-2 text-dark">
                  {sponsor.name}
                </p>
              <% end %>
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
