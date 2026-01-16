defmodule PearlWeb.Checkout.Components.InfoCard do
  @moduledoc """
    InfoCard for the checkout flow
  """
  use PearlWeb, :live_component
  alias Pearl.TicketTypes


  @impl true
  def render(assigns) do
    ~H"""
      <div class="min-w-[420px]">
        <div class="sticky top-6 max-w-[420px] h-[642px] bg-white rounded-4xl border border-gray-100 overflow-hidden">
            <div class="flex flex-col justify-between w-full h-full p-8">
              <div class="">
                {step_header(@step, @current_user.name)}

              </div>
              <div class="flex justify-center">
                <%= if @step == :choose_ticket do %>
                  <div class="w-[280px] h-[280px] flex items-center justify-center">
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
                <% else %>
                  <div class="relative w-80 h-80">
                    <div class="absolute inset-0 flex items-center justify-center">
                      <div class="relative w-[170px] h-[170px] rounded-full bg-linear-to-b from-gray-200 to-gray-400 shadow-inner">
                        <div class="absolute inset-0 flex items-center justify-center">
                          <span class="text-white text-6xl font-bold uppercase tracking-widest select-none">
                            <%= get_initials(@current_user.name) %>
                          </span>
                        </div>

                        <div class="absolute inset-0">
                          <%= for orb <- @active_orbs do %>
                            <% {key, status} = Map.to_list(orb) |> List.first() %>
                            <% key_str = to_string(key) %>
                            <div
                              id={"orb-#{key_str}"}
                              class="absolute w-12 h-12 transition-all duration-500 ease-out"
                              style={get_orb_position(get_orb_position(key_str))}
                            >
                              <div class={["relative rounded-full shadow-lg w-full h-full flex items-center justify-center transition-all overflow-hidden duration-700 ease-in-outbg-primary opacity-100", if status == "active" do
                                  "bg-primary scale-100"
                                else
                                  "bg-primary/40 scale-90"
                                end]}>

                                <div class={["absolute inset-0 bg-linear-[15deg] from-white/45 via-white/20 to-white/05 pointer-events-none", "#{if status == "inactive", do: "from-white/80 via-white/60 to-white/40"}"]}></div>
                                <.icon
                                  name={get_orb_icon(key_str)}
                                  class={[
                                    "w-6 h-6 text-white relative z-10 transition-transform duration-500",
                                    if(status == "active", do: "scale-100", else: "scale-90")
                                  ]}
                                />
                              </div>
                            </div>
                          <% end %>
                        </div>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
              <div class="flex flex-col items-end">
                <div class="">
                  <span class="text-xl"> Preço atual: </span>
                  <span class="text-3xl font-bold">{get_formated_price(@ticket.price)}</span>
                </div>
                <div>
                  <span>INCL. IVA</span>
                </div>
              </div>
            </div>
        </div>
      </div>
    """
  end

  defp get_orb_icon("disabilities"), do: "hero-exclamation-circle"
  defp get_orb_icon("allergens"), do: "hero-x-mark"
  defp get_orb_icon("tshirt_size"), do: "hero-swatch"
  defp get_orb_icon("diet"), do: "hero-cake"
  defp get_orb_icon("transport"), do: "hero-truck"
  defp get_orb_icon("attended"), do: "hero-backward"
  defp get_orb_icon("user"), do: "hero-user"
  defp get_orb_icon(_), do: "hero-question-mark-circle"

  defp get_orb_position("disabilities"), do: "top-right"
  defp get_orb_position("allergens"), do: "left-bottom"
  defp get_orb_position("tshirt_size"), do: "top"
  defp get_orb_position("diet"), do: "right"
  defp get_orb_position("transport"), do: "top-left"
  defp get_orb_position("attended"), do: "left"
  defp get_orb_position("user"), do: "right-bottom"

  defp get_orb_position("top"), do: "top: -24px; left: 50%; transform: translateX(-50%);"
  defp get_orb_position("top-right"), do: "top: 15%; right: 15%; transform: translate(50%, -50%);"
  defp get_orb_position("right"), do: "top: 50%; right: -24px; transform: translateY(-50%);"
  defp get_orb_position("right-bottom"), do: "top: 85%; right: 15%; transform: translate(50%, -50%);"
  defp get_orb_position("top-left"), do: "top: 15%; left: 15%; transform: translate(-50%, -50%);"
  defp get_orb_position("left"), do: "top: 50%; left: -24px; transform: translateY(-50%);"
  defp get_orb_position("left-bottom"), do: "top: 85%; left: 15%; transform: translate(-50%, -50%);"

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:tabs, [])}
  end

  @impl true
  def update(assigns, socket) do
    ticket = case Map.get(assigns.ticket_data, "ticket_type_id") do
      nil -> %{}
      ticket_type_id -> TicketTypes.get_ticket_type!(ticket_type_id)
    end

    {:ok,
     socket
     |> assign(assigns)
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
    Number.Currency.number_to_currency(price, precision: 2, unit: "€", separator: ",", delimiter: "", format: "%n%u")
  end

  def step_header(step, form \\ nil)

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

  def step_header(5, _),
    do:
      "Já temos tudo. Confirma se está tudo certo e verifica o teu email com o código que enviamos. A seguir, serás redirecionado para o pagamento."

  def step_header(_, _), do: ""

end
