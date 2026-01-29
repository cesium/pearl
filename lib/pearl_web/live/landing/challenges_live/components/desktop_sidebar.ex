defmodule PearlWeb.Landing.ChallengesLive.Components.DesktopSidebar do
  @moduledoc """
  Desktop sidebar with challenge list navigation
  """
  use Phoenix.Component

  attr :challenges, :list, required: true
  attr :selected_challenge_id, :string, required: true

  def desktop_sidebar(assigns) do
    ~H"""
    <div class="hidden xl:flex flex-col">
      <ul class="select-none text-base space-y-1">
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
                  do: "text-primary",
                  else: "text-black/50 hover:text-gray-300"
                )
              ]}>
                <%= if @selected_challenge_id == challenge.id do %>
                  <div class="absolute left-0 top-0 bottom-0 w-1 bg-primary rounded-r"></div>
                <% end %>

                <div class={[
                  "font-semibold mb-1",
                  if(@selected_challenge_id == challenge.id, do: "text-primary", else: "text-black")
                ]}>
                  {challenge.name}
                </div>

                <div class={[
                  "text-sm leading-relaxed",
                  if(@selected_challenge_id == challenge.id,
                    do: "text-primary/80",
                    else: "text-black/50"
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
