defmodule PearlWeb.Landing.FAQLive.Components.Faq do
  @moduledoc false
  use PearlWeb, :component

  attr :id, :string, required: true
  attr :topic, :string, required: true
  attr :question, :string, required: true
  attr :answer, :string, required: true
  attr :is_article, :boolean, default: false

  def faq(assigns) do
    ~H"""
    <div id={@id} class="bg-white border-b-2 border-background-muted">
      <div class="w-full flex flex-row items-center">
        <div class="h-min py-4 pl-6">
          <p class="uppercase text-sm opacity-50">{@topic}</p>
          <h2 class="select-none text-lg">
            {@question}
          </h2>
        </div>
        <button
          class="ml-auto"
          phx-click={
            JS.toggle(
              to: "#faq-answer-#{@id}",
              in: {"", "opacity-0 max-h-0", "opacity-100 max-h-48"},
              out: {"", "opacity-100 max-h-48", "opacity-0 max-h-0"}
            )
            |> JS.toggle(to: "#faq-answer-toggle-show-#{@id}")
            |> JS.toggle(to: "#faq-answer-toggle-hide-#{@id}")
          }
        >
          <.icon name="hero-arrow-right" class="mr-6 w-6 h-6 cursor-pointer opacity-50" />
        </button>
      </div>
      <div id={"faq-answer-#{@id}"} class="overflow-hidden pb-4" style="display: none;">
        <p>{@answer}</p>
      </div>
    </div>
    """
  end
end
