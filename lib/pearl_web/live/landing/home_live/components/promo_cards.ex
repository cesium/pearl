defmodule PearlWeb.Landing.HomeLive.Components.PromoCards do
  use PearlWeb, :component
  import PearlWeb.Landing.Components.PromoCard

  def promo_cards(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row gap-[10px] w-full items-stretch">
      <.promo_card
        title={gettext("A cereja no topo do bolo")}
        description={
          gettext(
            "Do ENEI, levarás sempre como recordação, no mínimo, o teu kit de boas vindas. Porém, ao participares em desafios, habilitas-te a ganhar <strong>grandes prémios</strong>."
          )
        }
        text_color="text-light"
        bg_color="bg-black"
        button_text={gettext("conhece os desafios")}
        button_link={~p"/challenges"}
      >
        <img
          src={~p"/images/prizes.webp"}
          alt={gettext("Prizes")}
          class="w-auto max-w-lg lg:max-w-none object-contain object-bottom"
        />
      </.promo_card>
      <.promo_card
        title={gettext("Regime tudo-incluído")}
        description={
          gettext(
            "Na compra do bilhete para o ENEI 2026, podes assegurar a tua alimentação e alojamento, juntamente com uma ótima experiência, claro."
          )
        }
        text_color="text-black"
        bg_color="bg-light-muted"
        button_text={gettext("mais informações")}
        button_link="/tickets"
      >
        <.included_items />
      </.promo_card>
    </div>
    """
  end

  defp included_items_data do
    [
      %{
        icon: "ticket.svg",
        title: gettext("Bilhete"),
        description: nil,
        border: "#f18f01",
        bg: "#ffdeae"
      },
      %{
        icon: "coffee.svg",
        title: gettext("Coffee Breaks"),
        description: gettext("Lanches de manhã e de tarde garantidos."),
        border: "#f18f01",
        bg: "#ffdeae"
      },
      %{
        icon: "food.svg",
        title: gettext("Alimentação"),
        description: gettext("Podes incluir almoços e jantares no teu bilhete."),
        border: "#e35c3b",
        bg: "#f5c4b8"
      },
      %{
        icon: "bed.svg",
        title: gettext("Alojamento"),
        description: gettext("Na Universidade do Minho ou na Pousada da Juventude."),
        border: "#2e86ab",
        bg: "#bfe0ee"
      },
      %{
        icon: "bus.svg",
        title: gettext("Transportes"),
        description: gettext("Entre o evento e o alojamento."),
        border: "#ae5583",
        bg: "#e9c3d7"
      }
    ]
  end

  defp included_items(assigns) do
    assigns = assign(assigns, :items, included_items_data())

    ~H"""
    <div class="flex flex-wrap lg:hidden justify-center pb-[60px] pt-[40px] px-2">
      <div
        :for={item <- @items}
        class="w-15 h-15 flex items-center justify-center"
        style={"background-color: #{item.bg}"}
      >
        <img src={~p"/images/icons/#{item.icon}"} class="w-8 h-8" />
      </div>
    </div>
    <div class="hidden lg:grid grid-cols-2 w-full gap-2 py-[83px] px-[44px]">
      <.info_card
        :for={item <- Enum.filter(@items, & &1.description)}
        title={item.title}
        description={item.description}
        icon={item.icon}
        icon_bg={item.bg}
        icon_border={item.border}
      />
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :icon, :string, required: true
  attr :icon_bg, :string, required: true
  attr :icon_border, :string, required: true

  defp info_card(assigns) do
    ~H"""
    <div class="rounded-[30px] p-[20px] w-full bg-light-shade">
      <div class="flex items-center gap-3 mb-2">
        <div
          class="rounded-lg border p-1"
          style={"background-color: #{@icon_bg}; border-color: #{@icon_border}"}
        >
          <img src={~p"/images/icons/#{@icon}"} class="w-[1em] h-[1em] block" />
        </div>
        <span class="font-semibold text-black">{@title}</span>
      </div>
      <p class="text-black text-sm text-left">{@description}</p>
    </div>
    """
  end
end
