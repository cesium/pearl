defmodule PearlWeb.Checkout.Components.TicketForm do
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

        <h2 class="font-extrabold text-2xl mb-2">Allergens</h2>
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
            class="flex place-items-center gap-2 bg-transparent hover:bg-transparent text-primary p-1!"
            type="button"
            phx-value={:intended_transport_to_enei}
            phx-click="remove_response"
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
              class="flex place-items-center gap-2 bg-transparent hover:bg-transparent text-primary p-1!"
              type="button"
              phx-value={:has_attended_enei_before}
              phx-click="remove_response"
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
        <.data_line key="Disabilities" value={Map.get(@ticket_data, "disabilities")} />
        <.data_line key="Allergens" value={Map.get(@ticket_data, "allergens") || "No allergies"} />
        <.data_line key="T-shirt size" value={Map.get(@ticket_data, "tshirt_size")} />
        <.data_line key="Diet" value={Map.get(@ticket_data, "diet")} />
        <.data_line
          key="How are you getting to ENEI?"
          value={Map.get(@ticket_data, "intended_transport_to_enei") || "No data"}
        />
        <.data_line
          key="Have you been to ENEI before?"
          value={Map.get(@ticket_data, "has_attended_enei_before") || "No data"}
        />
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
end
