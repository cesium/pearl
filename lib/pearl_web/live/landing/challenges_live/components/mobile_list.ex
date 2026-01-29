defmodule PearlWeb.Landing.ChallengesLive.Components.MobileList do
  @moduledoc """
  Mobile challenge list view
  """
  use Phoenix.Component
  use PearlWeb, :html

  attr :challenges, :list, required: true

  def mobile_list(assigns) do
    ~H"""
    <div class="space-y-2">
      <%= for challenge <- @challenges do %>
        <button
          phx-click="mobile_select_challenge"
          phx-value-challenge_id={challenge.id}
          class="w-full text-left p-6"
        >
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <h3 class="font-bold text-black text-lg mb-2">
                {challenge.name}
              </h3>
              <p class="text-gray-500 text-sm line-clamp-2">
                {truncate_text(challenge.description, 100)}
              </p>
            </div>
            <.icon name="hero-chevron-right" class="w-6 h-6 text-gray-400 shrink-0 ml-4" />
          </div>
        </button>
      <% end %>
    </div>
    """
  end

  defp truncate_text(nil, _length), do: ""

  defp truncate_text(text, length) do
    if String.length(text) > length do
      String.slice(text, 0, length) <> "..."
    else
      text
    end
  end
end
