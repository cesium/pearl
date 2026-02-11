defmodule PearlWeb.Landing.ChallengesLive.Components.ChallengesList do
  @moduledoc """
  Challenge list component - handles both desktop sidebar and mobile list views
  """
  use Phoenix.Component
  use PearlWeb, :html

  attr :challenges, :list, required: true
  attr :selected_challenge_id, :string, default: nil

  def challenges_list(assigns) do
    ~H"""
    <div class="hidden xl:flex flex-col">
      <ul class="font-terminal select-none text-base space-y-1">
        <%= for challenge <- @challenges do %>
          <li class="transition-all ease-in-out">
            <button
              phx-click="challenge_change"
              class="w-full text-left group"
              phx-value-challenge_id={challenge.id}
            >
              <div class={[
                "relative pl-6 py-4",
                if(@selected_challenge_id == challenge.id,
                  do: "text-[#8B1538]",
                  else: "text-gray-400 hover:text-gray-300"
                )
              ]}>
                <%= if @selected_challenge_id == challenge.id do %>
                  <div class="absolute left-0 top-0 bottom-0 w-1 bg-[#8B1538] rounded-r"></div>
                <% end %>

                <div class={[
                  "uppercase font-bold mb-1",
                  if(@selected_challenge_id == challenge.id, do: "text-[#8B1538]", else: "text-white")
                ]}>
                  {challenge.name}
                </div>

                <div class={[
                  "text-sm leading-relaxed",
                  if(@selected_challenge_id == challenge.id,
                    do: "text-[#8B1538]/80",
                    else: "text-gray-500"
                  )
                ]}>
                  {truncate_text(challenge.description, 80)}
                </div>
              </div>
            </button>
          </li>
        <% end %>
      </ul>
    </div>
    <div class="xl:hidden space-y-2">
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
