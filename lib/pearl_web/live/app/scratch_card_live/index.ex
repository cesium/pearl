defmodule PearlWeb.App.ScratchCardLive.Index do
  use PearlWeb, :app_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: :scrath_card)}
  end
end
