defmodule PearlWeb.Landing.Components.PromoCard do
  use Phoenix.Component
  use PearlWeb, :html

  @moduledoc """
  Renders a single promo card with a title, description, button, and optional inner content.
  """

  import PearlWeb.Components.Button

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :text_color, :string, required: true
  attr :bg_color, :string, required: true
  attr :button_text, :string, required: true
  attr :button_link, :string, required: true
  slot :inner_block, required: false

  def promo_card(assigns) do
    ~H"""
    <section class={"relative w-full self-stretch overflow-hidden #{@text_color} #{@bg_color}"}>
      <div class="relative z-10 flex flex-col items-center text-center w-full h-full pt-[40px] lg:pt-8 gap-[20px]">
        <div class="shrink-0 pt-8 px-[40px] lg:px-[44px]">
          <h1 class="text-3xl font-semibold mb-4 text-balance">
            {@title}
          </h1>
          <p class="max-w-xl leading-relaxed">
            {raw(@description)}
          </p>
        </div>
        <.link navigate={@button_link}>
          <.primary_button title={@button_text} class="text-sm" />
        </.link>
        <div class="relative w-full flex mt-auto justify-center">
          {render_slot(@inner_block)}
        </div>
      </div>
    </section>
    """
  end
end
