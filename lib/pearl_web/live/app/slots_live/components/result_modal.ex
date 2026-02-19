defmodule PearlWeb.App.SlotsLive.Components.ResultModal do
  @moduledoc """
  Slots result modal component.
  """
  use PearlWeb, :component

  import PearlWeb.Components.Modal

  attr :id, :string, required: true
  attr :multiplier, :integer, required: true
  attr :winnings, :integer, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}

  # We pass these classes down to the base modal's attributes
  attr :wrapper_class, :string, default: ""
  attr :content_class, :string, default: "bg-primary ring-4 ring-white py-14 px-5"

  def result_modal(assigns) do
    ~H"""
    <.modal
      id={@id}
      show={@show}
      on_cancel={@on_cancel}
      wrapper_class={@wrapper_class}
      body_class={@content_class}
      phx-hook="Confetti"
      data-win?={@multiplier > 1}
    >
      <div
        id={"#{@id}-content-inner"}
        class="font-terminal uppercase text-3xl md:text-4xl text-center"
      >
        {get_spin_result_title(@multiplier)}
      </div>
      <div class="text-center mt-4">
        {get_spin_result_text(@multiplier, @winnings)}
      </div>
    </.modal>
    """
  end

  defp get_spin_result_title(multiplier) do
    cond do
      multiplier == 1 -> gettext("Bet refunded! 💰")
      multiplier > 1 -> gettext("You won tokens! 🎉")
    end
  end

  defp get_spin_result_text(multiplier, winnings) do
    cond do
      multiplier == 1 ->
        gettext("Phew, your bet was refunded! Will you try your luck with another spin?")

      multiplier > 1 ->
        gettext("Congratulations! You won %{winnings} tokens!", winnings: winnings)
    end
  end
end
