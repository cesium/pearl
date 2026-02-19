defmodule PearlWeb.App.ScratchCardLive.Index do
  use PearlWeb, :app_view

  alias Pearl.Minigames
  alias Pearl.Uploaders

  import PearlWeb.App.WheelLive.Components.ResultModal
  import PearlWeb.App.WheelLive.Components.LatestWins
  import PearlWeb.App.WheelLive.Components.Awards

  @max_wins 6

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Minigames.subscribe_to_scratch_card_config_update("is_active")
      Minigames.subscribe_to_scratch_card_config_update("price")
      Minigames.subscribe_to_scratch_card_config_update("drops")
      Minigames.subscribe_to_scratch_card_wins()
    end

    {:ok,
     socket
     |> assign(current_page: :scratch_card)
     |> assign(is_scratching?: false)
     |> assign(is_revealed: false)
     |> assign(attendee_tokens: socket.assigns.current_user.attendee.tokens)
     |> assign(scratch_card_price: Minigames.get_scratch_card_price())
     |> assign(scratch_card_active?: Minigames.scratch_card_active?())
     |> assign(result: nil)
     |> assign(:drops, Minigames.list_scratch_card_drops())
     |> assign(:latest_wins, Minigames.scratch_card_latest_wins(@max_wins))}
  end

  @impl true
  def handle_event("buy-card", _params, socket) do
    case Minigames.buy_scratch_card(socket.assigns.current_user.attendee) do
      {:ok, %{scratch_card_preloaded: scratch_card}} ->
        result =
          if scratch_card.drop do
            %{type: Minigames.get_drop_type(scratch_card.drop), drop: scratch_card.drop}
          else
            %{type: nil, drop: nil}
          end

        {:noreply,
         socket
         |> assign(:is_scratching?, true)
         |> assign(:current_scratch_card, scratch_card)
         |> assign(:current_symbols, Minigames.get_symbols_from_scratch_card(scratch_card))
         |> assign(:result, result)
         |> assign(
           :attendee_tokens,
           socket.assigns.attendee_tokens - socket.assigns.scratch_card_price
         )
         |> push_event("scratch-card", %{card_id: scratch_card.id})}

      {:error, error} ->
        {:noreply,
         socket
         |> assign(:is_scratching?, false)
         # Restore attendee tokens if the purchase fails (client side)
         |> assign(
           :attendee_tokens,
           socket.assigns.attendee_tokens + socket.assigns.scratch_card_price
         )
         |> put_flash(:error, error)}
    end
  end

  def handle_event("scratch-completed", %{"card_id" => card_id}, socket) do
    cond do
      is_nil(socket.assigns[:current_scratch_card]) ->
        {:noreply, put_flash(socket, :error, "There are no scratch cards active")}

      socket.assigns.current_scratch_card.id != card_id ->
        {:noreply, put_flash(socket, :error, "Scratch card id is invalid")}

      true ->
        {:noreply,
         socket
         |> assign(is_scratching?: false)
         |> assign(is_revealed: true)}

        # Todo: add tokens on client side;
    end
  end

  @impl true
  def handle_event("close-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(is_revealed: false)
     |> assign(result: nil)
     |> assign(current_scratch_card: nil)
     |> push_event("clear-card", %{})}
  end

  @impl true
  def handle_info({"is_active", value}, socket) do
    {:noreply, socket |> assign(:scratch_card_active?, value)}
  end

  @impl true
  def handle_info({"price", value}, socket) do
    {:noreply, socket |> assign(:scratch_card_price, value)}
  end

  @impl true
  def handle_info({"drops", drops}, socket) do
    {:noreply, socket |> assign(:scratch_card_drops, drops)}
  end

  defp can_scratch?(scratch_card_active?, tokens, price, is_scratching?) do
    !is_scratching? && scratch_card_active? && tokens >= price
  end
end
