defmodule PearlWeb.Landing.ChallengesLive.Components.ChallengesList do
  @moduledoc """
  Challenge list component - handles both desktop sidebar and mobile list views
  """
  use Phoenix.Component
  use PearlWeb, :html
  import PearlWeb.Components.Markdown

  attr :challenges, :list, required: true
  attr :selected_challenge_id, :string, default: nil

  def challenges_list(assigns) do
    ~H"""
    <div class="hidden xl:flex flex-col">
      <ul class="select-none space-y-2.5">
        <%= for challenge <- @challenges do %>
          <li class="transition-all ease-in-out">
            <button
              phx-click="challenge_change"
              class="w-full text-left group cursor-pointer"
              phx-value-challenge_id={challenge.id}
            >
              <div class={[
                "pl-5 pr-4 py-4",
                if(@selected_challenge_id == challenge.id, do: "border-l-4 border-primary", else: "")
              ]}>
                <div class={[
                  "font-semibold",
                  if(@selected_challenge_id == challenge.id, do: "text-primary", else: "text-black")
                ]}>
                  {challenge.name}
                </div>

                <div class={[
                  "leading-relaxed line-clamp-2",
                  if(@selected_challenge_id == challenge.id,
                    do: "text-primary",
                    else: "text-black/50"
                  )
                ]}>
                  <.markdown content={challenge.description} />
                </div>
              </div>
            </button>
          </li>
        <% end %>
      </ul>
    </div>
    <div class="xl:hidden space-y-2.5">
      <%= for challenge <- @challenges do %>
        <button
          phx-click="mobile_select_challenge"
          phx-value-challenge_id={challenge.id}
          class="w-full text-left py-4"
        >
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <h3 class="font-semibold text-black">
                {challenge.name}
              </h3>
              <div class="text-black/50 leading-relaxed line-clamp-2">
                <.markdown content={challenge.description} />
              </div>
            </div>
            <.icon name="hero-chevron-right" class="w-6 h-6 text-black/30 shrink-0 ml-4" />
          </div>
        </button>
      <% end %>
    </div>
    """
  end
end
