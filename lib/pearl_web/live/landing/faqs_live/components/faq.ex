defmodule PearlWeb.Landing.FAQLive.Components.Faq do
  @moduledoc false
  use PearlWeb, :component

  alias Pearl.Event

  attr :id, :string, required: true
  attr :topic, :string, required: true
  attr :question, :string, required: true
  attr :answer, :string, required: true
  attr :is_article, :boolean, default: false

  def faq(assigns) do
    ~H"""
    <div id={@id} class="bg-white border-b-2 border-background-muted group">
      <div class="w-full flex flex-row items-center">
        <div class="h-min py-4 pl-6">
          <p class="uppercase text-sm opacity-50">{@topic}</p>
          <h2 class="select-none text-lg">
            {@question}
          </h2>
        </div>
        <button
          :if={!@is_article}
          class="ml-auto"
          phx-click={
            JS.toggle(
              to: "#faq-answer-#{@id}",
              in: {"", "opacity-0 max-h-0", "opacity-100 max-h-48"},
              out: {"", "opacity-100 max-h-48", "opacity-0 max-h-0"}
            )
            |> JS.toggle_class("rotate-90", to: ".faq-answer-toggle-#{@id}")
          }
        >
          <.icon
            name="hero-arrow-right"
            class={"mr-6 w-6 h-6 cursor-pointer opacity-50 transition-transform faq-answer-toggle-#{@id}"}
          />
        </button>
        <.link
          :if={@is_article}
          class="ml-auto"
          navigate={~p"/faqs/#{Event.slugify(@question)}"}
        >
          <.icon
            name="hero-arrow-right"
            class={"mr-6 w-6 h-6 cursor-pointer opacity-50 transition-transform faq-answer-toggle-#{@id}"}
          />
        </.link>
      </div>
      <div
        :if={!@is_article}
        id={"faq-answer-#{@id}"}
        class="overflow-hidden pb-4 px-6"
        style="display: none;"
      >
        <p>{@answer}</p>
      </div>
    </div>
    """
  end
end
