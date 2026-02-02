defmodule PearlWeb.Checkout.Components.InfoCard do
  @moduledoc """
    InfoCard for the checkout flow
  """
  use PearlWeb, :live_component
  alias Pearl.TicketTypes
  import PearlWeb.Components.Ticket

  @impl true
  def render(assigns) do
    ~H"""
    <div class={[
      "w-full md:w-[420px]",
      if @payment_completed do
        "w-full! transition-all duration-3000"
      end
    ]}>
      <div class={[
        "bg-white rounded-4xl border border-gray-100 overflow-hidden transition-all duration-700 ease-out md:w-[420px]",
        if @payment_completed do
          "w-full! transition-all duration-3000"
        end
      ]}>
        <div class="flex flex-col justify-between w-full p-6 sm:p-8 min-h-[400px] md:h-[660px]">
          <div class="">
            <%= if @step != :confirm_email do %>
              {step_header(@step, Map.get(@current_user, :name, nil))}
            <% end %>
          </div>
          <%= case @step do %>
            <% :registration -> %>
              <div class="flex justify-center">
                <div class="relative w-full md:w-80 md:h-80">
                  <div class="absolute inset-0 flex items-center justify-center">
                    <div class="relative w-36 h-36 sm:w-[48] sm:h-[48] md:w-[170px] md:h-[170px] rounded-full bg-linear-to-b from-[#D9D9D9] to-[#919191] shadow-[0_0_60px_0_rgba(0,0,0,0.2)] justify-center place-items-center flex">
                      <.icon name="hero-user" class="w-16 h-16 md:w-24 md:h-24 text-white" />
                    </div>
                  </div>
                </div>
              </div>
            <% :choose_ticket -> %>
              <div class="w-full flex justify-center">
                <div class="h-fit flex items-center justify-center">
                  <div class="flex flex-wrap justify-center max-w-60">
                    <%= for {perk, i} <- Enum.with_index(@ticket.perks || []) do %>
                      <div
                        id={"perk-wrapper-#{i}"}
                        class="animate-slide-in-right"
                        style={"animation-delay: #{i * 100}ms; animation-fill-mode: both;"}
                      >
                        <.live_component
                          module={PearlWeb.Checkout.Components.PrettyIcon}
                          id={"perk-icon-#{i}"}
                          perk={perk}
                        />
                      </div>
                    <% end %>
                  </div>
                </div>
              </div>
            <% :conclusion -> %>
              <.ticket
                class="flex justify-center md:block md:-ml-96 h-[98px] md:h-[250px]!"
                svg_class="h-full!"
                attendee={@current_user.name}
                ticket_type={@ticket.name}
              />
            <% :payment -> %>
              <.ticket
                class="flex justify-center md:block md:-ml-96 h-[98px] md:h-[250px]!"
                svg_class="h-full!"
                attendee={@current_user.name}
                ticket_type={@ticket_type.name}
              />
            <% :payment_status -> %>
              <div class="relative w-full h-full">
                <div class={[
                  "absolute inset-0 flex flex-col items-start justify-center p-8 transition-all duration-1000 ease-out z-20",
                  if(@payment_completed,
                    do: "opacity-100 translate-x-0 transition-all delay-2000 duration-2000",
                    else: "opacity-0 -translate-x-8 transition-all duration-2000"
                  )
                ]}>
                  <div class="space-y-3 max-w-md">
                    <h2 class="text-2xl md:text-3xl font-bold text-dark">
                      Bem-vindo ao ENEI!
                    </h2>
                    <p class="text-lg text-dark/90">
                      É um gosto ter-te connosco, {get_display_name(@current_user.name)}.
                    </p>
                    <.primary_button
                      title="página inicial"
                      phx-click="redirect-to-home"
                      phx-target={@myself}
                    />
                  </div>
                </div>
                <div class={[
                  "absolute inset-0 z-10 flex items-center transition-all duration-1000 ease-out",
                  if(@payment_completed,
                    do:
                      "justify-end opacity-0 lg:opacity-100 pointer-events-none md:pointer-events-auto",
                    else: "justify-end opacity-100"
                  )
                ]}>
                  <.ticket
                    class="h-[98px] md:h-[250px]"
                    svg_class="h-full!"
                    attendee={@current_user.name}
                    ticket_type={@ticket_type.name}
                  />
                </div>
              </div>
            <% _ -> %>
              <div class="flex justify-center">
                <div class="relative w-full md:w-80 h-fit">
                  <div class="absolute inset-0 flex items-center justify-center">
                    <div class="relative w-32 h-32 md:w-[170px] md:h-[170px] rounded-full bg-linear-to-b from-[#D9D9D9] to-[#919191] shadow-[0_0_60px_0_rgba(0,0,0,0.2)]">
                      <div class="absolute inset-0 flex items-center justify-center">
                        <span class="text-white text-4xl md:text-6xl font-bold uppercase tracking-widest select-none">
                          {get_initials(Map.get(@current_user, :name, nil))}
                        </span>
                      </div>
                      <div class="absolute inset-0">
                        <%= for orb <- @active_orbs || [] do %>
                          <% {key, status} = Map.to_list(orb) |> List.first() %>
                          <% key_str = to_string(key) %>
                          <div
                            id={"orb-#{key_str}"}
                            class={"absolute w-12 h-12 transition-all duration-500 ease-out z-0 sm:z-30 #{get_orb_position_class(get_orb_position(key_str))}"}
                          >
                            <div class={[
                              "relative rounded-full shadow-lg w-full h-full flex items-center justify-center transition-all overflow-hidden duration-700 ease-in-outbg-primary opacity-100",
                              if status == "active" do
                                "bg-primary scale-100 animate-scale-up-down"
                              else
                                "bg-primary/40 scale-90"
                              end
                            ]}>
                              <div class={[
                                "absolute inset-0 bg-linear-[15deg] from-white/45 via-white/20 to-white/05 pointer-events-none",
                                "#{if status == "inactive", do: "from-white/80 via-white/60 to-white/40"}"
                              ]}>
                              </div>
                              <.icon
                                name={get_orb_icon(key_str)}
                                class={"w-5 h-5 text-white relative z-10 transition-transform duration-500 #{if status == "active", do: "scale-100", else: "scale-90"}"}
                              />
                            </div>
                          </div>
                        <% end %>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
          <% end %>
          <%= if Map.has_key?(@ticket, :price) do %>
            <div class="flex flex-col items-end">
              <div class="">
                <span class="text-xl"> Preço atual: </span>
                <span class="text-3xl font-bold">
                  {get_formated_price(Map.get(@ticket, :price))}
                </span>
              </div>
            </div>
          <% else %>
            <div></div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp get_orb_position_class(position), do: "orb-pos-#{position}"

  defp get_orb_icon("disabilities"), do: "fa-crutch-solid"
  defp get_orb_icon("allergens"), do: "fa-hand-dots-solid"
  defp get_orb_icon("tshirt_size"), do: "fa-shirt-solid"
  defp get_orb_icon("diet"), do: "fa-apple-whole-solid"
  defp get_orb_icon("transport"), do: "fa-car-solid"
  defp get_orb_icon("attended"), do: "fa-backward-solid"
  defp get_orb_icon("user"), do: "fa-user-solid"
  defp get_orb_icon(_), do: "hero-question-mark-circle"

  defp get_orb_position("disabilities"), do: "top-right"
  defp get_orb_position("allergens"), do: "left-bottom"
  defp get_orb_position("tshirt_size"), do: "right-bottom"
  defp get_orb_position("diet"), do: "right"
  defp get_orb_position("transport"), do: "top-left"
  defp get_orb_position("attended"), do: "left"
  defp get_orb_position("user"), do: "top"

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:tabs, [])
     |> assign(:payment_completed, false)}
  end

  @impl true
  def handle_event("redirect-to-home", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/")}
  end

  @impl true
  def update(assigns, socket) do
    ticket_data = Map.get(assigns, :ticket_data, %{})
    current_user = Map.get(assigns, :current_user, %{})
    step = Map.get(assigns, :step, nil)
    active_orbs = Map.get(assigns, :active_orbs, [])

    ticket =
      case Map.get(ticket_data, "ticket_type_id") do
        nil -> %{}
        ticket_type_id -> TicketTypes.get_ticket_type!(ticket_type_id)
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:ticket_data, ticket_data)
     |> assign(:current_user, current_user)
     |> assign(:step, step)
     |> assign(:active_orbs, active_orbs)
     |> assign(:ticket, ticket)}
  end

  defp get_initials(name) do
    case String.split(name || "", " ", trim: true) do
      [] -> nil
      [single] -> String.slice(single, 0, 1)
      names -> "#{String.first(List.first(names))}#{String.first(List.last(names))}"
    end
  end

  defp get_formated_price(price) do
    Number.Currency.number_to_currency(price,
      precision: 2,
      unit: "€",
      separator: ",",
      delimiter: "",
      format: "%n%u"
    )
  end

  defp get_display_name(name) do
    case String.split(name || "", " ", trim: true) do
      [] ->
        ""

      [single] ->
        String.capitalize(single)

      names ->
        first = names |> List.first() |> String.capitalize()
        last = names |> List.last() |> String.capitalize()
        "#{first} #{last}"
    end
  end

  def step_header(step, form \\ nil)

  def step_header(:registration, _),
    do: "Para fazer o teu registo, precisamos de alguns dados pessoais teus."

  def step_header(:choose_ticket, _),
    do: "Vê os benefícios de cada bilhete para escolheres o teu."

  def step_header(:precautions, name) do
    first_name =
      name
      |> String.split(" ", trim: true)
      |> List.first()

    "Olá, #{first_name}! Se tiveres alguma incapacidade (motora, visual, auditiva) ou alergia alimentar, pedimos que nos informes."
  end

  def step_header(:informations, _),
    do:
      "Ok! Para finalizar, precisamos de saber mais alguns detalhes, e também temos algumas curiosidades."

  def step_header(:conclusion, _),
    do:
      "Já temos tudo. Confirma se está tudo certo. A seguir, serás redirecionado para o pagamento."

  def step_header(:payment, _),
    do: "Podes proceder agora ao pagamento do bilhete."

  def step_header(:payment_status, _),
    do: ""

  def step_header(_, _), do: ""
end
