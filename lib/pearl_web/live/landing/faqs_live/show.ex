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
      <div class="max-w-4xl mx-auto pt-16 pb-12 px-4">
        <.link navigate={~p"/faqs"}>
          <.icon name="hero-arrow-left" class="w-8 h-8 cursor-pointer mb-4" />
        </.link>
        <p class="opacity-50 uppercase pb-2">{@faq.topic}</p>
        <h1 class="text-3xl font-bold mb-4">{@faq.question}</h1>
      </div>
      <div class="bg-white h-96">
        <div class="max-w-4xl mx-auto pb-16 px-4">
          <.markdown content={@faq.answer} class="[&_h1]:text-xl [&_h1]:font-semibold" />
        </div>
      </div>
    </div>
    """
  end
end
