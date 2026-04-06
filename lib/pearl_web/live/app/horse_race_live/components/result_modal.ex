defmodule PearlWeb.App.HorseRaceLive.Components.ResultModal do
  @moduledoc """
  Horse Race result modal component.
  """
  use PearlWeb, :component

  import PearlWeb.Components.Modal

  attr :id, :string, required: true
  attr :race_result, :map, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}

  attr :wrapper_class, :string, default: ""

  attr :content_class, :string,
    default: "bg-dark w-full max-w-lg mx-auto border border-light/10 ring-white p-8 pt-9"

  attr :container_class, :string, default: "flex min-h-full items-center justify-center"

  def result_modal(assigns) do
    ~H"""
    <.modal
      id={@id}
      show={@show}
      on_cancel={@on_cancel}
      wrapper_class={@wrapper_class}
      body_class={@content_class}
      container_class={@container_class}
      phx-hook="Confetti"
      data-is_win={@race_result.winnings > 0}
    >
      <div class="flex flex-col items-center gap-6">
        <!-- Horse Icon -->
        <div class="flex justify-center w-full mt-4 mb-4">
          <div class="relative w-24 h-24 rounded-full border border-light/10 bg-dark-muted/20 flex items-center justify-center">
            <div
              class={[
                "horse-icon shrink-0",
                "horse-rest",
                "opacity-100",
                horse_variant_class(@race_result.winning_horse)
              ]}
              style="transform: scale(0.5); transform-origin: center;"
            >
            </div>
          </div>
        </div>

        <span class="text-center space-y-2">
          <h2 class="uppercase text-3xl font-bold">
            <%= if @race_result.winnings > 0 do %>
              {gettext("Ganhaste")}
            <% else %>
              {gettext("Perdeste")}
            <% end %>
          </h2>
          <p class="text-lg text-light/50">
            <%= if @race_result.winnings > 0 do %>
              {gettext("O cavalo #%{horse} foi o grande vencedor e trouxe-te sorte!",
                horse: @race_result.winning_horse
              )}
            <% else %>
              {gettext("O cavalo #%{horse} cruzou a meta primeiro. Tenta outra vez!",
                horse: @race_result.winning_horse
              )}
            <% end %>
          </p>
        </span>

        <div class="flex flex-col items-center gap-3 mt-2 w-full bg-dark-muted/10 p-4 rounded-xl border border-light/5">
          <p class="uppercase text-xs tracking-wide text-light/50">{gettext("Resultado")}</p>
          <p class="font-bold text-2xl text-center text-light">
            <%= if @race_result.winnings > 0 do %>
              {gettext("+%{winnings} tokens", winnings: format_tokens(@race_result.winnings))}
            <% else %>
              {gettext("-%{losses} tokens", losses: format_tokens(@race_result.losses))}
            <% end %>
          </p>
        </div>
      </div>
    </.modal>
    """
  end

  defp format_tokens(value) when is_integer(value), do: Float.round(value * 1.0, 2)
  defp format_tokens(value) when is_float(value), do: Float.round(value, 2)
  defp format_tokens(%Decimal{} = value), do: value |> Decimal.to_float() |> Float.round(2)
  defp format_tokens(value), do: value

  defp horse_variant_class(horse_number) do
    case rem(horse_number - 1, 3) do
      0 -> "horse-variant-gold"
      1 -> "horse-variant-brown"
      2 -> "horse-variant-grey"
    end
  end
end
