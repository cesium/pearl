defmodule PearlWeb.Landing.HomeLive.Components.Scroller do
  @moduledoc false
  use PearlWeb, :component

  @doc """
  Infinite scrolling text scroller
  """

  attr :text, :string, required: true
  attr :speed, :string, default: "20s"
  attr :pausable, :boolean, default: true
  attr :class, :string, default: nil

  def scroller(assigns) do
    ~H"""
    <div class={["relative flex w-full font-thin overflow-hidden bg-light py-7 group", @class]}>
      <div
        class="flex whitespace-nowrap scroller-content"
        style={"animation: infinite-scroll #{@speed} linear infinite;"}
      >
        <div class="flex shrink-0 items-center gap-10 px-7">
          <%= for _ <- 1..5 do %>
            <span class="font-grotesk text-xl text-dark-muted lowercase tracking-tight">
              {@text}
            </span>
          <% end %>
        </div>

        <div class="flex shrink-0 items-center gap-10 px-7" aria-hidden="true">
          <%= for _ <- 1..5 do %>
            <span class="font-grotesk text-xl text-dark-muted lowercase tracking-tight">
              {@text}
            </span>
          <% end %>
        </div>
      </div>

      <div class="absolute inset-y-0 left-0 w-96 bg-linear-to-r from-light to-transparent pointer-events-none"></div>
      <div class="absolute inset-y-0 right-0 w-96 bg-linear-to-l from-light to-transparent pointer-events-none"></div>
    </div>
    """
  end
end
