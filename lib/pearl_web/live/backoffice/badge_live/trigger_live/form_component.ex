defmodule PearlWeb.Backoffice.BadgeLive.TriggerLive.FormComponent do
  use PearlWeb, :live_component

  alias Pearl.Contest
  import PearlWeb.Components.{Forms, Button}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        stack_header_on_mobile
        title={@title}
        subtitle={
          gettext(
            "If the following event happens, for any attendee, the %{badge_name} badge is automatically awarded to them.",
            badge_name: @badge.name
          )
        }
      >
        <.simple_form
          for={@form}
          id="trigger-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="w-full space-y-2 text-dark dark:text-light">
            <div class="flex flex-row gap-2 items-center flex-wrap">
              <p>
                {gettext("Award %{badge_name} when an attendee", badge_name: @badge.name)}
              </p>
              <.field
                field={@form[:event]}
                label_class="hidden"
                wrapper_class="!mb-0 w-38"
                type="select"
                options={events_options(@events)}
              />
            </div>
          </div>
          <:actions>
            <.backoffice_button phx-disable-with="Saving...">Save Trigger</.backoffice_button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:events, Contest.BadgeTrigger.events())}
  end

  @impl true
  def update(%{badge_trigger: trigger} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Contest.change_badge_trigger(trigger))
     end)}
  end

  @impl true
  def handle_event("validate", %{"badge_trigger" => badge_trigger}, socket) do
    changeset = Contest.change_badge_trigger(socket.assigns.badge_trigger, badge_trigger)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"badge_trigger" => badge_trigger}, socket) do
    save_trigger(
      socket,
      socket.assigns.action,
      Map.put(badge_trigger, "badge_id", socket.assigns.badge.id)
    )
  end

  defp save_trigger(socket, :triggers_edit, trigger_params) do
    case Contest.update_badge_trigger(socket.assigns.badge_trigger, trigger_params) do
      {:ok, _trigger} ->
        {:noreply,
         socket
         |> put_flash(:success, gettext("Trigger do badge atualizada com sucesso."))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_trigger(socket, :triggers_new, trigger_params) do
    case Contest.create_badge_trigger(trigger_params) do
      {:ok, _trigger} ->
        {:noreply,
         socket
         |> put_flash(:success, gettext("Trigger do badge criada com sucesso."))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp events_options(events) do
    Enum.map(events, &{event_text(&1), &1})
  end

  defp event_text(:upload_cv_event), do: gettext("uploads their cv")
  defp event_text(:play_slots_event), do: gettext("plays the slots minigame")
  defp event_text(:play_coin_flip_event), do: gettext("plays the coin flip minigame")
  defp event_text(:play_wheel_event), do: gettext("plays the wheel minigame")
  defp event_text(:play_horse_race_event), do: gettext("plays the horse race minigame")
  defp event_text(:play_scratch_card_event), do: gettext("plays the scratch card minigame")

  defp event_text(:redeem_spotlighted_badge_event),
    do: gettext("redeems the badge of a company that is on spotlight")

  defp event_text(:link_credential_event), do: gettext("links their credential")
  defp event_text(event), do: event
end
