defmodule PearlWeb.Backoffice.LockersLive.ConfigureLockers.FormComponent do
  @moduledoc """
  LiveComponent used to configure the maximum number of lockers.
  """

  use PearlWeb, :live_component

  alias Ecto.Changeset
  alias Pearl.Lockers

  import PearlWeb.Components.{Button, Forms}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={@title}
        subtitle={gettext("Configure the maximum number of Lockers")}
        stack_header_on_mobile
      >
        <.simple_form
          for={@form}
          id="lockers-config-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="w-full space-y-4">
            <div>
              <%= if @max_lockers > 0 do %>
                <p class="text-danger-700 font-semibold">
                  {gettext("Current configured lockers: %{max_lockers}", max_lockers: @max_lockers)}
                </p>
              <% else %>
                <p>
                  {gettext("No lockers configured yet.")}
                </p>
              <% end %>
            </div>

            <.field
              field={@form[:max_lockers]}
              type="number"
              label="Max Number of Lockers"
              required
            />
          </div>

          <:actions>
            <.backoffice_button
              data-confirm="Do you want to save these changes? It can break stuff if you are not careful"
              phx-disable-with="Saving..."
            >
              {gettext("Save Settings")}
            </.backoffice_button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    current_count = Lockers.get_current_lockers_count()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:max_lockers, current_count)
     |> assign_new(:form, fn ->
       to_form(%{"max_lockers" => current_count}, as: :lockers_configuration)
     end)}
  end

  @impl true
  def handle_event("validate", params, socket) do
    current_count = Lockers.get_current_lockers_count()
    max_lockers = get_in(params, ["lockers_configuration", "max_lockers"])

    changeset = locker_config_changeset(max_lockers, current_count)

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate, as: :lockers_configuration))}
  end

  @impl true
  def handle_event("save", %{"lockers_configuration" => %{"max_lockers" => max_lockers}}, socket) do
    current_count = Lockers.get_current_lockers_count()
    changeset = locker_config_changeset(max_lockers, current_count)

    if changeset.valid? do
      new_max = Changeset.get_field(changeset, :max_lockers)

      case Lockers.configure_lockers(new_max) do
        {:ok, lockers} ->
          {:noreply,
           socket
           |> assign(:max_lockers, new_max)
           |> assign(:form, to_form(%{"max_lockers" => new_max}, as: :lockers_configuration))
           |> put_flash(:info, "Configured #{length(lockers)} new lockers successfully.")
           |> push_navigate(to: socket.assigns.patch)}

        {:error, :out_of_bound} ->
          {:noreply,
           socket
           |> assign(form: to_form(changeset, action: :validate, as: :lockers_configuration))
           |> put_flash(:error, "Max lockers must be greater than the current configured amount.")}

        {:error, failed, _changeset, _successful} ->
          {:noreply,
           socket
           |> put_flash(:error, "Failed while configuring lockers (#{inspect(failed)}).")}
      end
    else
      {:noreply,
       assign(socket, form: to_form(changeset, action: :validate, as: :lockers_configuration))}
    end
  end

  defp locker_config_changeset(max_lockers, current_count) do
    {%{}, %{max_lockers: :integer}}
    |> Changeset.cast(%{max_lockers: max_lockers}, [:max_lockers])
    |> Changeset.validate_required([:max_lockers])
    |> Changeset.validate_number(:max_lockers, greater_than: current_count)
  end
end
