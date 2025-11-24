defmodule PearlWeb.Backoffice.MinigamesLive.HorseRace.FormComponent do
  @moduledoc false
  use PearlWeb, :live_component

  import PearlWeb.Components.Forms

  alias Ecto.Changeset
  alias Pearl.Minigames

  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={gettext("Horse Race Configuration")}
        subtitle={gettext("Configures horse race minigame's internal settings.")}
      >
        <:actions>
          <.link patch={~p"/dashboard/minigames/horse_race/simulation"}>
            <.button>
              <.icon name="hero-play" class="w-5" />
            </.button>
          </.link>
        </:actions>
        <div class="my-8">
          <.form
            id="horse-race-config-form"
            for={@form}
            phx-submit="save"
            phx-change="validate"
            phx-target={@myself}
          >
            <div class="grid grid-cols-2 gap-6">
              <.field
                field={@form[:is_active]}
                name="is_active"
                label={gettext("Active")}
                type="switch"
                help_text={gettext("Defines whether the horse race minigame is active.")}
                wrapper_class="my-6"
              />
              <.field
                field={@form[:multiplier]}
                name="multiplier"
                type="number"
                step="0.1"
                label={gettext("Win Multiplier")}
                help_text={
                  gettext(
                    "Multiplier applied to winnings when betting on the winning horse. E.g., 2.5x means bettors get 2.5x their bet."
                  )
                }
              />
              <.field
                field={@form[:duration_minutes]}
                name="duration_minutes"
                type="number"
                label={gettext("Race Duration (minutes)")}
                help_text={gettext("How long the race animation will run in minutes.")}
              />
              <.field
                field={@form[:entry_fee]}
                name="entry_fee"
                type="number"
                label={gettext("Entry Fee (tokens)")}
                help_text={gettext("Cost in tokens to participate in the horse race.")}
              />
            </div>

            <div class="mt-8 p-4 bg-lightShade/20 dark:bg-darkShade/20 rounded-lg">
              <h3 class="font-semibold mb-3">{gettext("Game Settings")}</h3>
              <div class="grid grid-cols-2 gap-6">
                <.field
                  field={@form[:number_of_horses]}
                  name="number_of_horses"
                  type="number"
                  label={gettext("Number of Horses")}
                  help_text={gettext("How many horses will race (3-8).")}
                />
                <.field
                  field={@form[:house_fee]}
                  name="house_fee"
                  type="number"
                  step="0.1"
                  label={gettext("House Fee (%)")}
                  help_text={gettext("Percentage of pot taken as house fee (0-100).")}
                />
              </div>
            </div>

            <div class="flex flex-row-reverse mt-8">
              <.button phx-disable-with={gettext("Saving...")}>
                {gettext("Save Configuration")}
              </.button>
            </div>
          </.form>
        </div>
      </.page>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       form:
         to_form(
           %{
             "is_active" => Minigames.horse_race_active?(),
             "multiplier" => Minigames.get_horse_race_multiplier(),
             "duration_minutes" => Minigames.get_horse_race_duration(),
             "entry_fee" => Minigames.get_horse_race_entry_fee(),
             "number_of_horses" => Minigames.get_horse_race_number_of_horses(),
             "house_fee" => Minigames.get_horse_race_house_fee()
           },
           as: :horse_race_configuration
         )
     )}
  end

  def handle_event("validate", params, socket) do
    changeset = validate_configuration(params)

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate, as: :horse_race_configuration))}
  end

  def handle_event("save", params, socket) do
    if valid_config?(params) do
      Minigames.change_horse_race_multiplier(params["multiplier"] |> String.to_float())
      Minigames.change_horse_race_duration(params["duration_minutes"] |> String.to_integer())
      Minigames.change_horse_race_entry_fee(params["entry_fee"] |> String.to_integer())

      Minigames.change_horse_race_number_of_horses(
        params["number_of_horses"]
        |> String.to_integer()
      )

      Minigames.change_horse_race_house_fee(params["house_fee"] |> String.to_float())
      Minigames.change_horse_race_active("true" == params["is_active"])

      {:noreply, socket |> push_patch(to: ~p"/dashboard/minigames/")}
    else
      {:noreply, socket}
    end
  end

  defp validate_configuration(params) do
    {%{},
     %{
       is_active: :boolean,
       multiplier: :float,
       duration_minutes: :integer,
       entry_fee: :integer,
       number_of_horses: :integer,
       house_fee: :float
     }}
    |> Changeset.cast(params, [
      :is_active,
      :multiplier,
      :duration_minutes,
      :entry_fee,
      :number_of_horses,
      :house_fee
    ])
    |> Changeset.validate_required([
      :multiplier,
      :duration_minutes,
      :entry_fee,
      :number_of_horses,
      :house_fee
    ])
    |> Changeset.validate_number(:multiplier, greater_than: 0)
    |> Changeset.validate_number(:duration_minutes, greater_than: 0)
    |> Changeset.validate_number(:entry_fee, greater_than_or_equal_to: 0)
    |> Changeset.validate_number(:number_of_horses,
      greater_than_or_equal_to: 3,
      less_than_or_equal_to: 8
    )
    |> Changeset.validate_number(:house_fee,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100
    )
  end

  defp valid_config?(params) do
    validation = validate_configuration(params)
    validation.errors == []
  end
end
