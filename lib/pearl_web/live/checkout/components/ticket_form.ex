defmodule PearlWeb.Checkout.Components.TicketForm do
  @moduledoc """
    Module for the ticket checkout forms
  """
  use PearlWeb, :live_component
  alias Pearl.TicketTypes

  def render(assigns) do
    ~H"""
    <div class="px-4 lg:px-10 pb-8">
      <%= case @step do %>
        <% :choose_ticket -> %>
          <.choose_ticket_step form={@form} ticket_data={@ticket_data} ticket_types={@ticket_types} />
        <% :precautions -> %>
          <.precautions_step form={@form} />
        <% :informations -> %>
          <.informations_step form={@form} />
        <% :conclusion -> %>
          <.conclusion_step form={@form} ticket_data={@ticket_data} />
      <% end %>
    </div>
    """
  end

  defp choose_ticket_step(assigns) do
    ~H"""
    <div class="flex flex-col gap-10">
      <% selected_ticket_type =
        TicketTypes.get_ticket_type!(Map.get(assigns.ticket_data, "ticket_type_id")) %>
      <div>
        <h2 class="font-extrabold text-lg mb-1">Escolha o teu bilhete</h2>
        <span>
          Os tipos de bilhetes incluem diferentes benefícios.
        </span>
        <.simple_form phx-change="validate" for={@form} id="choose_ticket-form">
          <.input
            field={@form[:ticket_type_id]}
            type="select"
            options={@ticket_types |> Enum.map(&{&1.name, &1.id})}
            variant={:flushed}
            label=""
          />
        </.simple_form>
      </div>
      <div>
        <h2 class="font-semibold text-lg mb-2">Benefícios deste bilhete:</h2>
        <ul class="flex flex-col gap-2">
          <%= for perk <- selected_ticket_type.perks do %>
            <li class="flex items-center gap-2">
              <span class="flex" style={"color: #{perk.color};"}>
                <.icon name="hero-check" class="size-4" />
              </span>
              <span class="text-lg">{perk.description}</span>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp precautions_step(assigns) do
    ~H"""
    <div class="">
      <.simple_form phx-change="validate" for={@form} id="precautions-form">
        <h2 class="font-extrabold text-lg mb-1">Incapacidades</h2>
        <span class="mb-3 block">
          Descreve qualquer incapacidade que tenhas que nós devamos saber para poder adaptar a tua experiência.
        </span>
        <.input
          class="resize-none"
          variant={:flushed}
          rows="3"
          placeholder="Escreve aqui..."
          type="textarea"
          field={@form[:disabilities]}
        />

        <h2 class="font-extrabold text-lg mb-1">Alergénios*</h2>
        <span class="mb-3 block">
          Se tiveres alguma alergia a alimentos, seleciona a opção correspondente e descrimina os alimentos a que és sensível.
        </span>
        <.input
          type="radio"
          field={@form[:has_allergens]}
          class="text-base!"
          options={[
            {"Não tenho nenhuma alergia", "no"},
            {"Sou alérgico(a) aos seguintes alimentos: ", "yes"}
          ]}
        />

        <%= if Phoenix.HTML.Form.input_value(@form, :has_allergens) == "yes" do %>
          <.input
            class="resize-none"
            variant={:flushed}
            rows="3"
            placeholder="Escreve aqui..."
            type="textarea"
            field={@form[:allergens]}
          />
        <% end %>
      </.simple_form>
    </div>
    """
  end

  defp informations_step(assigns) do
    ~H"""
    <div class="">
      <.simple_form phx-change="validate" for={@form} id="informations-form">
        <h2 class="font-extrabold text-lg mb-1">Tamanho de T-shirt*</h2>
        <span>
          Para a tua conveniência, deixa já registado o tamanho de T-Shirt que costumas vestir. Em todo o caso, não ficas limitado ao tamanho que escolheres.
        </span>
        <.input
          type="segmented-radio"
          field={@form[:tshirt_size]}
          options={[{"XS", "xs"}, {"S", "s"}, {"M", "m"}, {"L", "l"}, {"XL", "xl"}, {"XXL", "xxl"}]}
        />

        <h2 class="font-extrabold text-lg mb-1">Diet*</h2>
        <span>
          Caso sejas vegetariano ou vegan, podemos ter isso em atenção.
        </span>
        <.input
          type="radio"
          field={@form[:diet]}
          class="text-base!"
          options={[
            {"Dieta sem restrições", "no_restrictions"},
            {"Dieta vegetariana", "vegetarian"},
            {"Dieta vegan", "vegan"}
          ]}
        />

        <div class="flex flex-col gap-5">
          <div>
            <h2 class="font-extrabold text-lg mb-1">Como vens para o ENEI?</h2>
            <span>
              Esta pergunta é opcional e destina-se apenas a fins estatísticos. Que meio de transporte pretendes utilizar para o ENEI?
            </span>

            <.input
              type="radio"
              field={@form[:intended_transport_to_enei]}
              class="text-base!"
              options={[
                {"Vou no meu próprio veículo", "own_vehicle"},
                {"Vou de boleia no veículo de outra pessoa", "someone_else"},
                {"Vou de transporte coletivo externo ao ENEI (autocarro, comboio ou avião)",
                 "external"},
                {"Vou recorrer a um serviço de táxi ou TVDE", "taxi_or_tvde"},
                {"Vou a pé", "walking"}
              ]}
            />
          </div>
          <.button
            class="flex place-items-center gap-2 bg-transparent hover:bg-transparent text-primary p-1! w-fit cursor-pointer transition-opacity disabled:opacity-50 disabled:cursor-default"
            type="button"
            phx-value-field="intended_transport_to_enei"
            phx-click="remove_response"
            disabled={is_nil(@form.params["intended_transport_to_enei"])}
          >
            <.icon name="hero-backspace" class="w-5 h-5" /> remover resposta
          </.button>
        </div>

        <div class="flex flex-col gap-5">
          <div>
            <h2 class="font-extrabold text-lg mb-1">Já vieste ao ENEI antes?</h2>
            <span>
              Esta pergunta é de resposta opcional e apenas para fins estatísticos.  Já alguma vez participaste numa edição anterior do ENEI?
            </span>

            <.input
              type="radio"
              field={@form[:has_attended_enei_before]}
              class="text-base!"
              options={[
                {"Não", "no"},
                {"Sim, incluindo uma ou mais edições em Braga", "yes_elsewhere"},
                {"Sim, mas nunca uma edição em Braga", "yes_braga"}
              ]}
            />
          </div>
          <.button
            class="flex place-items-center gap-2 bg-transparent hover:bg-transparent text-primary p-1! w-fit cursor-pointer transition-opacity disabled:opacity-50 disabled:cursor-default"
            type="button"
            phx-value-field="has_attended_enei_before"
            phx-click="remove_response"
            disabled={is_nil(@form.params["has_attended_enei_before"])}
          >
            <.icon name="hero-backspace" class="w-5 h-5" /> remover resposta
          </.button>
        </div>
      </.simple_form>
    </div>
    """
  end

  defp conclusion_step(assigns) do
    ~H"""
    <div class="py-8">
      <h2 class="text-2xl sm:text-3xl font-bold mb-2">The data you will submit</h2>
      <div>
        <%= for {key, value} <- filter_data(@ticket_data) do %>
          <.data_line key={humanize_key(key)} value={humanize_value(value)} />
        <% end %>
      </div>
    </div>
    """
  end

  defp filter_data(ticket_data) do
    has_allergens = Map.get(ticket_data, "has_allergens")

    ticket_data
    |> Enum.reject(fn {key, value} ->
      String.starts_with?(to_string(key), "_unused") ||
        key == "ticket_type_id" ||
        value == "" ||
        (key == "allergens" and has_allergens == "no") ||
        (key == "has_allergens" and has_allergens == "yes")
    end)
  end

  defp data_line(assigns) do
    ~H"""
    <div class="flex flex-col lg:flex-row w-full place-items-start">
      <span class="min-w-1/2 font-bold">{@key}:</span>
      <p class="lg:self-center">{@value}</p>
    </div>
    """
  end

  defp humanize_key("disabilities"), do: "Incapacidades"
  defp humanize_key("allergens"), do: "Alergénios"
  defp humanize_key("has_allergens"), do: "Alergénios"
  defp humanize_key("tshirt_size"), do: "Tamanho de T-shirt"
  defp humanize_key("diet"), do: "Dieta"
  defp humanize_key("intended_transport_to_enei"), do: "Como vai deslocar-se para o ENEI?"
  defp humanize_key("has_attended_enei_before"), do: "Já participou no ENEI anteriormente?"
  defp humanize_key(key), do: key

  defp humanize_value("no_restrictions"), do: "Sem restrições"
  defp humanize_value("vegetarian"), do: "Vegetariana"
  defp humanize_value("vegan"), do: "Vegana"
  defp humanize_value("xs"), do: "XS"
  defp humanize_value("s"), do: "S"
  defp humanize_value("m"), do: "M"
  defp humanize_value("l"), do: "L"
  defp humanize_value("xl"), do: "XL"
  defp humanize_value("xxl"), do: "XXL"
  defp humanize_value("own_vehicle"), do: "Vou no meu próprio veículo"
  defp humanize_value("someone_else"), do: "Vou de boleia no veículo de outra pessoa"

  defp humanize_value("external"),
    do: "Vou de transporte coletivo externo ao ENEI (autocarro, comboio ou avião)"

  defp humanize_value("taxi_or_tvde"), do: "Vou recorrer a um serviço de táxi ou TVDE"
  defp humanize_value("walking"), do: "Vou a pé"
  defp humanize_value("no"), do: "Não"
  defp humanize_value("yes_elsewhere"), do: "Sim, incluindo uma ou mais edições em Braga"
  defp humanize_value("yes_braga"), do: "Sim, mas nunca uma edição em Braga"
  defp humanize_value(nil), do: "No data"
  defp humanize_value(value), do: value
end
