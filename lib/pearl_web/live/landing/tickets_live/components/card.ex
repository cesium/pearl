defmodule PearlWeb.Landing.TicketsLive.Components.Card do
  @moduledoc """
  Tickets component.
  """
  use PearlWeb, :component

def card(assigns) do
  ~H"""
    <div class="w-full h-[476px] max-w-95 p-0.5" style="background: linear-gradient(to bottom right, rgba(0, 0, 0, 0.1) 0%, rgba(0, 0, 0, 0.05) 40%, transparent 46%);">    <div class="w-full h-full flex flex-col gap-5 justify-between bg-white overflow-hidden p-5 border-dark/20">
      <div class="flex flex-col gap-4">
        <div class="flex">
          <div :for={perk <- @ticket_type.perks} class="flex w-15 h-15 items-center place-content-center gap-2 p-2" style={"background-color: #{perk.color};"}>
            <.icon class="w-10 h-10" name={perk.icon} />
          </div>
        </div>
        <div class="flex flex-col gap-3">
          <span class="text-black text-2xl font-extrabold">{@ticket_type.name}</span>
          <div class="flex flex-col gap-3">
            <div :for={perk <- @ticket_type.perks} class="flex gap-2">
              <img
                src={~p"/images/check.svg"}
                alt={gettext("Check")}
                class=""
              />
              <span class="text-black text-lg">{perk.description}</span>
            </div>
          </div>
        </div>
      </div>
      <div class="flex gap-4">
        <div class="flex flex-col gap-2">
          <span class="text-black text-4xl font-extrabold">
                {Number.Currency.number_to_currency(@ticket_type.price, unit: "€", format: "%n%u", precision: 2, delimiter: ".", separator: ",")}
          </span>
          <span class="text-dark/50">INCL. IVA</span>
        </div>
        <div>
          <.link
            navigate={~p"/speakers"}
            class=""
            >
            <.button class="w-16 h-16 rounded-none bg-primary hover:bg-black cursor-pointer">
              <.icon name="hero-arrow-right" />
            </.button>
          </.link>
        </div>
      </div>
    </div>
  </div>
  """
end
end
