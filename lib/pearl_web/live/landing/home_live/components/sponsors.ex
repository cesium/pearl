defmodule PearlWeb.Landing.HomeLive.Components.Sponsors do
  @moduledoc false
  use PearlWeb, :component

  alias Pearl.Uploaders

  def sponsors(assigns) do
    ~H"""
    <div class="flex items-center justify-center flex-col py-14.5 bg-[#EFEFED]">
      <div class="flex flex-col gap-5 items-center text-black">
        <h2 class="flex font-semibold justify-center text-center text-3xl w-[580px]">
          {gettext("Um elenco de empresas que abre portas e janelas")}
        </h2>
        <p class="lg:px-52.5 text-center">
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
    <div class="flex flex-col justify-center">
      <div class="flex w-full flex-col items-center justify-center">
        <p class="uppercase font-light text-xl" style={"color: #{@tier.color}"}>
          <span class="font-semibold">{@tier.name}</span> sponsors
        </p>
        <div class="grid grid-cols-4 w-full lg:grid-cols-6 gap-x-12.5 gap-y-16 items-center justify-center pt-8">
          <%= for sponsor <- @sponsors |> Enum.shuffle() do %>
            <.link
              href={sponsor.url}
              target="_blank"
              class="opacity-80 hover:opacity-100 hover:scale-105 duration-500 transition-all mx-auto"
            >
              <%= if sponsor.logo do %>
                <div class="w-40 h-20 flex items-center justify-center">
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
