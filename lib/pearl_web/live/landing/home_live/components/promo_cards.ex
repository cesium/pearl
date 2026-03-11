defmodule PearlWeb.Landing.HomeLive.Components.PromoCards do
  use PearlWeb, :component

  @moduledoc """
  Renders the promo cards section for the landing page home view.
  """

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
        button_link={~p"/tickets"}
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
        border: nil,
        bg: "#f2bac1"
      },
      %{
        icon: "coffee.svg",
        title: gettext("Coffee Breaks"),
        description: gettext("Lanches de manhã e de tarde garantidos."),
        border: "#f18f01",
        bg: "#ffdeae",
        class: "ml-[5px] mr-[3px]",
        class_mobile: "ml-2"
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
        description: gettext("No pavilhão da Escola Secundária Alberto Sampaio."),
        border: "#2e86ab",
        bg: "#bfe0ee",
        class: "w-[22px] h-[22px]",
        class_mobile: "w-10 h-10"
      },
      %{
        icon: "apparel.svg",
        title: gettext("Kit de Participante"),
        description: gettext("Para começar bem o evento, um kit recheado de brindes incríveis."),
        border: "#ae5583",
        bg: "#e9c3d7",
        class: "w-[22px] h-[22px]",
        class_mobile: "w-10 h-10"
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
        <img
          src={~p"/images/icons/#{item.icon}"}
          class={"w-8 h-8 #{Map.get(item, :class_mobile, "")}"}
        />
      </div>
    </div>
    <div class="hidden lg:grid grid-cols-2 w-full gap-2 py-[83px] px-11">
      <.info_card
        :for={item <- Enum.filter(@items, & &1.description)}
        title={item.title}
        description={item.description}
        icon={item.icon}
        icon_bg={item.bg}
        icon_border={item.border}
        class={Map.get(item, :class, "")}
      />
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :icon, :string, required: true
  attr :icon_bg, :string, required: true
  attr :icon_border, :string, required: true
  attr :class, :string, default: ""

  defp info_card(assigns) do
    ~H"""
    <div class="rounded-[30px] p-5 w-full bg-radial from-mutedDark to-lightMuted/20">
      <div class="flex items-center gap-3 mb-2">
        <div
          class="rounded-lg border w-[26px] h-[26px] flex items-center justify-center"
          style={"background-color: #{@icon_bg}; border-color: #{@icon_border}"}
        >
          <img src={~p"/images/icons/#{@icon}"} class={"w-4 h-4 block #{@class}"} />
        </div>
        <span class="font-semibold text-black">{@title}</span>
      </div>
      <p class="text-black text-sm text-left">{@description}</p>
    </div>
    """
  end
end
