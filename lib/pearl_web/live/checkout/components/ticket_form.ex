defmodule PearlWeb.Checkout.Components.TicketForm do
  @moduledoc """
    Module for the ticket checkout forms
  """
  use PearlWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="px-10">
      <%= case @step do %>
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

  defp precautions_step(assigns) do
    ~H"""
    <div class="">
      <.simple_form phx-change="validate" for={@form} id="precautions-form">
        <h2 class="font-extrabold text-2xl mb-2">Disabilities</h2>
        <span class="mb-3 block">
          Please describe any disability you have that we should be aware of so that we can tailor your experience.
        </span>
        <.input
          class="bg-[#EFEFED] border-none pl-0 text-base placeholder:text-base resize-none"
          rows="3"
          placeholder="Write here..."
          type="textarea"
          field={@form[:disabilities]}
        />

        <div class="w-full h-0.5 bg-black/5"></div>

        <h2 class="font-extrabold text-2xl mb-2">Allergens*</h2>
        <span class="mb-3 block">
          If you have any food allergies, select the corresponding option and list the foods to which you are sensitive.
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
            class="bg-[#EFEFED] border-none pl-0 text-base placeholder:text-base resize-none"
            rows="3"
            placeholder="Write here..."
            type="textarea"
            field={@form[:allergens]}
          />
        <% end %>

        <div class="w-full h-0.5 bg-black/5"></div>
      </.simple_form>
    </div>
    """
  end

  defp informations_step(assigns) do
    ~H"""
    <div class="">
      <.simple_form phx-change="validate" for={@form} id="informations-form">
        <h2 class="font-extrabold text-2xl mb-2">T-shirt size*</h2>
        <span>
          For your convenience, please register the size of T-shirt you usually wear. In any case, you are not limited to the size you choose.
        </span>
        <.input
          type="radio"
          field={@form[:tshirt_size]}
          options={[{"XS", "xs"}, {"S", "s"}, {"M", "m"}, {"L", "l"}, {"XL", "xl"}, {"XXL", "xxl"}]}
        />

        <h2 class="font-extrabold text-2xl mb-2">Diet*</h2>
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
            <h2 class="font-extrabold text-2xl mb-2">How are you getting to ENEI?</h2>
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
            <h2 class="font-extrabold text-2xl mb-2">Have you been to ENEI before?</h2>
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
