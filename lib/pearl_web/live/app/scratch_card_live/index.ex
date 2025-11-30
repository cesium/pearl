defmodule PearlWeb.App.ScratchCardLive.Index do
  use PearlWeb, :app_view

  alias Pearl.Minigames

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: :scratch_card)
     |> assign(attendee_tokens: socket.assigns.current_user.attendee.tokens)
     |> assign(scratch_card_active?: Minigames.scratch_card_active?())
     |> assign(scratch_fee: Minigames.get_scratch_card_price())}
  end
end
