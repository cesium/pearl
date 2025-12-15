defmodule PearlWeb.RegistrationComponents do
  use PearlWeb, :component

  import PearlWeb.Landing.Components.Navbar
  import PearlWeb.Landing.Components.Footer

  slot :sidebar, required: true
  slot :header, required: false
  slot :inner_block, required: true

  def registration_layout(assigns) do
    ~H"""
    <.navbar
      pages={PearlWeb.Config.landing_pages()}
      registrations_open?={Pearl.Event.registrations_open?()}
      current_user={Map.get(assigns, :current_user)}
    />

    <div class="min-h-screen bg-background-muted text-dark font-grotesk pb-25">
      <div class="mx-auto px-5 sm:px-7.5 lg:px-10">
        <div class="py-10">
          {render_slot(@header)}
        </div>

        <div class="flex flex-col lg:flex-row gap-10 items-start relative">
          <div class="hidden lg:flex flex-col w-[400px] bg-light rounded-[40px] shadow-sm p-10 min-h-[625px] sticky top-10 overflow-hidden transition-all duration-300">
            {render_slot(@sidebar)}
          </div>

          <div class="flex-1 w-full p-10 sm:p-15">
            {render_slot(@inner_block)}
          </div>
        </div>
      </div>
    </div>

    <.footer>
      <:tip :if={
        Map.get(assigns, :current_page, nil) in [:home, :schedule, :speakers, :faqs] and
          Pearl.Event.get_feature_flag("challenges_enabled")
      }>
        Have you checked out the
        <.link class="underline" navigate={~p"/challenges"}>challenges</.link>
        yet? <.link href="https://www.youtube.com/watch?v=xvFZjo5PgG0" target="_blank">🏆</.link>
      </:tip>
    </.footer>
    """
  end

  attr :current_step, :integer, required: true

  def step_bar(assigns) do
    assigns =
      assign(assigns, :steps, [
        {1, "Tipo de bilhete"},
        {2, "Dados pessoais"},
        {3, "Precauções"},
        {4, "Informações"},
        {5, "Verificação"}
      ])

    ~H"""
    <div class="flex flex-col sm:flex-row items-start sm:items-center gap-5 sm:gap-10 mb-5 pb-5">
      <h2 class="text-2xl font-bold text-dark mr-5">Inscrição</h2>

      <div class="flex flex-wrap gap-2.5">
        <%= for {index, label} <- @steps do %>
          <div class={[
            "flex items-center gap-2.5 pr-12.5 py-1.25 border-b-[2.5px] transition-colors",
            if(@current_step == index,
              do: " border-primary text-primary font-bold",
              else: "border-dark-muted/20 text-dark-muted"
            )
          ]}>
            <span class={[
              "flex items-center justify-center w-6.25 h-6.25 text-[15px] font-bold",
              if(@current_step == index,
                do: " bg-primary text-light",
                else: "bg-dark-muted/20 text-dark-muted"
              )
            ]}>
              {index}
            </span>
            <span class="text-[17.5px]">{label}</span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
