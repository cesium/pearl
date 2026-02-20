defmodule PearlWeb.App.ScratchCardLive.Components.PaytableModal do
  @moduledoc """
  ScratchCard paytable modal component that shows winning patterns
  """

  use PearlWeb, :component

  alias Pearl.Minigames
  alias Pearl.Uploaders.ScratchCardSymbols
  import PearlWeb.Components.Modal

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :wrapper_class, :string, default: ""
  attr :on_cancel, JS, default: %JS{}

  attr :body_class, :string,
    default:
      "bg-primary ring-4 ring-white py-8 px-5 max-h-[500px] overflow-y-scroll scrollbar-hide"

  def paytable_modal(assigns) do
    drops = Minigames.list_scratch_card_drops()

    assigns = assign(assigns, drops: drops)

    ~H"""
    <.modal
      id={@id}
      show={@show}
      on_cancel={@on_cancel}
      wrapper_class={@wrapper_class}
      body_class={@body_class}
    >
      <h2 class="text-3xl font-terminal font-bold text-center mb-6">
        {gettext("PAYTABLE")}
      </h2>

      <div class="space-y-6" id="paytable-content" phx-hook="PaytableModal">
        <%= for drop <- @drops do %>
          <div class="flex items-center justify-between border-b border-white/20 pb-4 last:border-0">
            <div class="flex flex-col gap-1">
              <h3 class="text-xl font-terminal font-semibold uppercase">
                Prize name here
              </h3>
              <p class="text-sm text-slate-300">
                {gettext("Probability: %{probability}%",
                  probability: Float.round(drop.probability * 100, 4)
                )}
              </p>
            </div>

            <div class="flex items-center justify-between">
              <img
                :for={_i <- 1..3}
                src={
                  ScratchCardSymbols.url(
                    {drop.scratch_card_symbol.image, drop.scratch_card_symbol},
                    :original, signed: true)
                }
                class="w-full h-full object-cover"
                alt="Slot icon"
              />
            </div>
          </div>
        <% end %>
      </div>
    </.modal>
    """
  end
end
