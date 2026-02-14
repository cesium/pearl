defmodule PearlWeb.Landing.ChallengesLive.Components.ChallengeDetail do
  @moduledoc """
  Challenge detail component - handles both desktop card and mobile detail views
  """
  use Phoenix.Component
  use PearlWeb, :html
  import PearlWeb.Components.Markdown
  import PearlWeb.Landing.ChallengesLive.Components.Medal
  alias Pearl.Uploaders

  attr :challenge, :map, required: true

  def challenge_detail(assigns) do
    assigns = assign(assigns, :image_src, get_challenge_image(assigns.challenge))

    ~H"""
    <div class="hidden xl:flex">
      <div class="rounded-3xl shadow-lg overflow-hidden w-full bg-linear-to-b from-black/6 to-white">
        <div class="relative h-64 overflow-hidden flex items-end justify-center pt-12">
          <img
            src={@image_src}
            alt={@challenge.name}
            class="h-full w-auto object-contain"
          />
        </div>

        <div class="pl-12">
          <img
            src={~p"/images/bookshelf.svg"}
            alt="Bookshelf"
            class="w-full"
          />
        </div>

        <div class="px-12 pb-12 space-y-8">
          <h2 class="font-semibold select-none text-2xl text-black leading-tight">
            {@challenge.name}
          </h2>

          <div>
            <h3 class="font-semibold text-black mb-2">Como funciona</h3>
            <div class="text-black leading-relaxed">
              <.markdown
                content={@challenge.description}
                class="[&_a]:text-primary [&_a]:underline"
              />
            </div>
          </div>

          <div>
            <h3 class="font-semibold text-black mb-2">Prémios</h3>
            <div class="space-y-2">
              <%= for cp <- @challenge.prizes do %>
                <div class="flex items-center gap-2">
                  <.medal text={to_string(cp.place)} color={medal_color(cp.place)} />
                  <p class="text-black">
                    {cp.prize.name}
                  </p>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="xl:hidden">
      <button
        phx-click="mobile_back"
        class="flex items-center text-black font-semibold mb-6"
      >
        <.icon name="hero-chevron-left" class="w-6 h-6" />
        <span class="font-semibold">{@challenge.name}</span>
      </button>

      <div class="rounded-3xl shadow-lg overflow-hidden bg-linear-to-b from-black/6 to-white">
        <div class="relative h-32 overflow-hidden flex items-end justify-center pt-8">
          <img
            src={@image_src}
            alt={@challenge.name}
            class="h-full w-auto object-contain"
          />
        </div>

        <img
          src={~p"/images/bookshelf.svg"}
          alt="Bookshelf"
          class="w-full pl-8"
        />

        <div class="px-8 pb-8 space-y-4">
          <div>
            <h3 class="font-semibold text-black mb-2">Como funciona</h3>
            <div class="text-black leading-relaxed">
              <.markdown content={@challenge.description} class="[&_a]:text-primary [&_a]:underline" />
            </div>
          </div>

          <div>
            <h3 class="font-semibold text-black mb-2">Prémios</h3>
            <div class="space-y-2">
              <%= for cp <- @challenge.prizes do %>
                <div class="flex items-center gap-2">
                  <.medal text={to_string(cp.place)} color={medal_color(cp.place)} />
                  <p class="text-black">
                    {cp.prize.name}
                  </p>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp medal_color(1), do: "#B29C88"
  defp medal_color(2), do: "#9E9E9E"
  defp medal_color(_), do: "#866861"

  defp get_challenge_image(%{image: %{file_name: _}} = challenge) do
    Uploaders.Challenge.url({challenge.image, challenge})
  end

  defp get_challenge_image(_challenge) do
    "/images/prizes.png"
  end
end
