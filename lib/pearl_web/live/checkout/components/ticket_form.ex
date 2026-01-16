defmodule PearlWeb.Checkout.Components.TicketForm do
  @moduledoc """
    Module for the ticket checkout forms
  """
  use PearlWeb, :live_component
  alias Pearl.TicketTypes

  def render(assigns) do
    ~H"""
    <div class="px-10">
      <%= case @step do %>
        <% :choose_ticket -> %>
          <.choose_ticket_step form={@form} ticket_data={@ticket_data} ticket_types={@ticket_types}/>
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
        <% selected_ticket_type = TicketTypes.get_ticket_type!(Map.get(assigns.ticket_data, "ticket_type_id")) %>
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
                  <.icon name="hero-check" class="size-4"/>
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
        <h2 class="font-extrabold text-lg mb-1">Disabilities</h2>
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

        <h2 class="font-extrabold text-lg mb-1">Allergens*</h2>
        <span class="mb-3 block">
          Se tiveres alguma alergia a alimentos, seleciona a opção correspondente e descrimina os alimentos a que és sensível.
        </span>
        <.input
          type="radio"
          field={@form[:has_allergens]}
          options={[
            {"I don't have any allergies", "no"},
            {"I'm allergic to the following foods: ", "yes"}
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
        <h2 class="font-extrabold text-lg mb-1">T-shirt size*</h2>
        <span>
          For your convenience, please register the size of T-shirt you usually wear. In any case, you are not limited to the size you choose.
        </span>
        <.input
          type="radio"
          field={@form[:tshirt_size]}
          options={[{"XS", "xs"}, {"S", "s"}, {"M", "m"}, {"L", "l"}, {"XL", "xl"}, {"XXL", "xxl"}]}
        />

        <h2 class="font-extrabold text-lg mb-1">Diet*</h2>
        <span>If you are vegetarian or vegan, we can take this into account in your meals.</span>
        <.input
          type="radio"
          field={@form[:diet]}
          options={[
            {"Diet without restrictions", "no_restrictions"},
            {"Vegetarian diet", "vegetarian"},
            {"Vegan diet", "vegan"}
          ]}
        />

        <div class="flex flex-col gap-5">
          <div>
            <h2 class="font-extrabold text-lg mb-1">How are you getting to ENEI?</h2>
            <span>
              This question is optional and for statistical purposes only. What means of transportation do you intend to use for ENEI?
            </span>

            <.input
              type="radio"
              field={@form[:intended_transport_to_enei]}
              options={[
                {"I'll go in my own vehicle", "own_vehicle"},
                {"I'm getting a ride in someone else's vehicle", "someone_else"},
                {"I will be traveling by public transportation outside of ENEI (bus, train, or plane)",
                 "external"},
                {"I will use a taxi or private hire car service.", "taxi_or_tvde"},
                {"I'm walking", "walking"}
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
            <.icon name="hero-backspace" class="w-5 h-5" /> remove response
          </.button>
        </div>

        <div class="flex flex-col gap-5">
          <div>
            <h2 class="font-extrabold text-lg mb-1">Have you been to ENEI before?</h2>
            <span>
              This question is optional and for statistical purposes only. Have you ever participated in a previous edition of ENEI?
            </span>

            <.input
              type="radio"
              field={@form[:has_attended_enei_before]}
              options={[
                {"No", "no"},
                {"Yes, including one or more editions in Braga", "yes_elsewhere"},
                {"Yes, but never an edition in Braga", "yes_braga"}
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
            <.icon name="hero-backspace" class="w-5 h-5" /> remove response
          </.button>
        </div>
      </.simple_form>
    </div>
    """
  end

  defp conclusion_step(assigns) do
    ~H"""
    <div class="py-8">
      <h2 class="text-3xl font-bold mb-2">The data you will submit</h2>
      <div>
        <%= for {key, value} <- @ticket_data do %>
          <.data_line key={humanize_key(key)} value={humanize_value(value)} />
        <% end %>
      </div>
    </div>
    """
  end

  defp data_line(assigns) do
    ~H"""
    <div class="flex w-full place-items-center">
      <span class="w-1/2">{assigns.key}</span>
      <p class="text-sm">{assigns.value}</p>
    </div>
    """
  end

  defp humanize_key("disabilities"), do: "Disabilities"
  defp humanize_key("allergens"), do: "Allergens"
  defp humanize_key("tshirt_size"), do: "T-shirt size"
  defp humanize_key("diet"), do: "Diet"
  defp humanize_key("intended_transport_to_enei"), do: "How are you getting to ENEI?"
  defp humanize_key("has_attended_enei_before"), do: "Have you been to ENEI before?"
  defp humanize_key(key), do: key

  defp humanize_value("no_restrictions"), do: "No restrictions"
  defp humanize_value("vegetarian"), do: "Vegetarian"
  defp humanize_value("vegan"), do: "Vegan"
  defp humanize_value("xs"), do: "XS"
  defp humanize_value("s"), do: "S"
  defp humanize_value("m"), do: "M"
  defp humanize_value("l"), do: "L"
  defp humanize_value("xl"), do: "XL"
  defp humanize_value("xxl"), do: "XXL"
  defp humanize_value("own_vehicle"), do: "I'll go in my own vehicle"
  defp humanize_value("someone_else"), do: "I'm getting a ride in someone else's vehicle"

  defp humanize_value("external"),
    do: "I will be traveling by public transportation outside of ENEI (bus, train, or plane)"

  defp humanize_value("taxi_or_tvde"), do: "I will use a taxi or private hire car service."
  defp humanize_value("walking"), do: "I'm walking"
  defp humanize_value("no"), do: "No"
  defp humanize_value("yes_elsewhere"), do: "Yes, including one or more editions in Braga"
  defp humanize_value("yes_braga"), do: "Yes, but never an edition in Braga"
  defp humanize_value(nil), do: "No data"
  defp humanize_value(value), do: value
end
