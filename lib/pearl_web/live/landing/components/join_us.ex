defmodule PearlWeb.Landing.Components.JoinUs do
  @moduledoc false
  use PearlWeb, :component

  def join_us(assigns) do
    ~H"""
    <.link
      navigate={~p"/users/register"}
      class="flex items-center gap-2 h-10 px-5 bg-[#8B2332] text-white text-sm transition-all hover:bg-[#9a2a3a]"
    >
      <.icon name="hero-arrow-right" class="h-4 w-4" />
      <span>inscrição</span>
    </.link>
    """
  end
end
