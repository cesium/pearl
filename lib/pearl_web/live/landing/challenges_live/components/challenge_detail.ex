defmodule PearlWeb.Landing.ChallengesLive.Components.ChallengeDetail do
  @moduledoc """
  Challenge detail component - handles both desktop card and mobile detail views
  """
  use Phoenix.Component
  use PearlWeb, :html
  import PearlWeb.Components.Markdown

  attr :challenge, :map, required: true
  attr :view_mode, :string, default: "desktop", values: ~w(desktop mobile)

  def challenge_detail(assigns) do
    ~H"""
    <div :if={@view_mode == "desktop"} class="hidden xl:flex">
      <div class="bg-white rounded-3xl shadow-lg overflow-hidden w-full">
        <div class="relative h-64 bg-linear-to-br from-gray-100 via-gray-50 to-white overflow-hidden">
          <div class="absolute inset-0 bg-linear-to-br from-[#8B1538]/5 via-transparent to-gray-100">
          </div>
        </div>

        <div class="p-12">
          <h2 class="font-terminal uppercase select-none text-3xl text-black md:text-4xl xl:text-4xl mb-8 leading-tight">
            {@challenge.name}
          </h2>

          <div class="mb-10">
            <h3 class="text-xl font-bold text-black mb-4">Como funciona</h3>
            <div class="text-gray-700 leading-relaxed text-base">
              <.markdown
                content={@challenge.description}
                class="[&_a]:text-[#8B1538] [&_a]:underline"
              />
            </div>
          </div>

          <div>
            <h3 class="text-xl font-bold text-black mb-5">Prémios</h3>
            <div class="space-y-4">
              <%= for cp <- @challenge.prizes do %>
                <div class="flex items-center gap-3">
                  <.icon name="hero-trophy" class={"shrink-0 w-10 h-10 #{trophy_color(cp.place)}"} />
                  <p class="text-gray-900 font-medium text-base">
                    {cp.prize.name}
                  </p>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Mobile Detail View -->
    <div :if={@view_mode == "mobile"} class="xl:hidden">
      <button
        phx-click="mobile_back"
        class="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors mb-6"
      >
        <.icon name="hero-chevron-left" class="w-6 h-6" />
        <span class="font-medium">{@challenge.name}</span>
      </button>

      <div class="bg-white rounded-3xl shadow-lg overflow-hidden">
        <div class="relative h-48 bg-linear-to-br from-gray-100 via-gray-50 to-white">
          <div class="absolute inset-0 bg-linear-to-br from-[#8B1538]/5 via-transparent to-gray-100">
          </div>
        </div>

        <div class="p-8">
          <div class="mb-6">
            <h3 class="text-lg font-bold text-black mb-3">Como funciona</h3>
            <div class="text-gray-700 leading-relaxed text-sm">
              <.markdown content={@challenge.description} class="[&_a]:text-primary [&_a]:underline" />
            </div>
          </div>

          <div>
            <h3 class="text-lg font-bold text-black mb-4">Prémios</h3>
            <div class="space-y-3">
              <%= for cp <- @challenge.prizes do %>
                <div class="flex items-center gap-3">
                  <.icon name="hero-trophy" class={"shrink-0 w-8 h-8 #{trophy_color(cp.place)}"} />
                  <p class="text-gray-900 font-medium text-sm">
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

  defp trophy_color(1), do: "text-[#FFD700]"
  defp trophy_color(2), do: "text-[#C0C0C0]"
  defp trophy_color(_), do: "text-[#CD7F32]"
end
