defmodule PearlWeb.Landing.TicketsLive.Components.Card do
  @moduledoc """
  Tickets component.
  """
  use PearlWeb, :component

  def card(assigns) do
    ~H"""
    <div class="w-full h-full flex flex-col justify-between bg-white overflow-hidden">
      <div
        class="relative flex flex-col text-white p-4 bg-cover bg-center"
        style="background-image: url('/images/tickets/background.png')"
      >
        <div class="absolute bg-black/30 inset-0"></div>
        <span class="relative font-extrabold text-2xl">{assigns.ticket_type.name}</span>
        <span class="relative font-extrabold text-2xl">€{assigns.ticket_type.price}</span>
      </div>
      <div class="flex flex-col text-black p-8 gap-6 h-full justify-between">
        <div class="space-y-2">
          <span class="font-extrabold text-xl leading-tight block">
            {assigns.ticket_type.description}
          </span>
          <div class="h-1 w-12 bg-wine"></div>
        </div>
        <ul class="space-y-3 text-gray-700">
          <li class="flex items-start gap-3">
            <span class="text-wine mt-1">•</span>
            <span>Backstage access</span>
          </li>
          <li class="flex items-start gap-3">
            <span class="text-wine mt-1">•</span>
            <span>Private dinner with speakers</span>
          </li>
          <li class="flex items-start gap-3">
            <span class="text-wine mt-1">•</span>
            <span>Exclusive merch</span>
          </li>
        </ul>
      </div>
      <div class="flex justify-center place-items-center bg-wine">
        <.button
          class="rounded-none bg-transparent! text-white! px-1 py-5 cursor-pointer w-full h-full group flex justify-center items-center gap-2"
          phx-value-ticket_type_id={assigns.ticket_type.id}
        >
          <span class="text-sm group-hover:-translate-x-0.5 transition-all">Get this ticket</span>
          <.icon name="hero-arrow-right" class="h-4 w-4 group-hover:translate-x-0.5 transition-all" />
        </.button>
      </div>
    </div>
    """
  end
end
