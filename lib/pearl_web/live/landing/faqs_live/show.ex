defmodule PearlWeb.Landing.FAQLive.Show do
  use PearlWeb, :landing_view

  import PearlWeb.Components.Markdown

  alias Pearl.Event

  on_mount {PearlWeb.VerifyFeatureFlag, "faqs_enabled"}

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    faq = Event.get_faq_by_slug!(slug)

    {:ok,
     socket
     |> assign(:current_page, :faqs)
     |> assign(:faq, faq)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <!-- Article header section -->
      <div class="max-w-4xl mx-auto pt-16 pb-12 px-4 relative z-1">
        <.link navigate={~p"/faqs"}>
          <.icon name="hero-arrow-left" class="w-8 h-8 cursor-pointer mb-4" />
        </.link>
        <p class="opacity-50 uppercase pb-2">{@faq.topic}</p>
        <h1 class="text-3xl font-bold mb-4">{@faq.question}</h1>
        <img
          class="overflow-hidden absolute right-0 -bottom-24 select-none"
          src="/images/information.svg"
        />
      </div>
      <div class="bg-white relative z-10">
        <div class="max-w-4xl mx-auto px-4 py-8">
          <.markdown
            content={@faq.answer}
            class="[&_h1]:text-2xl [&_h1]:font-semibold [&_h1]:pt-2 [&_h2]:text-xl [&_h2]:font-semibold [&_h3]:text-lg [&_h3]:font-semibold [&_blockquote]:w-full [&_blockquote]:text-center [&_blockquote]:font-semibold [&_li]:list-disc [&_li]:ml-6 [&_a]:text-primary [&_a]:underline"
          />
        </div>
      </div>
    </div>
    """
  end
end
