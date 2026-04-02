defmodule PearlWeb.Backoffice.ScheduleLive.CalendarPictures.FormComponent do
  @moduledoc false
  use PearlWeb, :live_component

  alias Pearl.Activities
  alias Pearl.Uploaders.Schedule

  import PearlWeb.Components.ImageUploader

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page title={@title} subtitle={gettext("Upload an image for this day's calendar.")}>
        <.simple_form
          for={@form}
          id="calendar-pictures-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="w-full flex flex-col gap-4">
            <div class="flex flex-col gap-2">
              <.label>{gettext("Image")}</.label>
              <.image_uploader
                class="w-full aspect-video"
                upload={@uploads.image}
                icon="hero-photo"
                image={
                  Schedule.url({@calendar_picture.image, @calendar_picture}, :original, signed: true)
                }
              />
            </div>
          </div>
          <:actions>
            <.backoffice_button phx-disable-with="Saving...">Save</.backoffice_button>
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
     |> assign(:uploaded_files, [])
     |> allow_upload(:image,
       accept: Schedule.extension_whitelist(),
       max_entries: 1
     )}
  end

  @impl true
  def update(%{calendar_picture: calendar_picture} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Activities.change_calendar_picture(calendar_picture))
     end)}
  end

  @impl true
  def handle_event("validate", %{"calendar_picture" => calendar_picture}, socket) do
    changeset =
      Activities.change_calendar_picture(socket.assigns.calendar_picture, calendar_picture)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    save_calendar_picture(socket, socket.assigns.action)
  end

  defp save_calendar_picture(socket, :calendar_pictures_edit) do
    calendar_picture = socket.assigns.calendar_picture
    params = %{"date" => Date.to_iso8601(calendar_picture.date)}

    result =
      if calendar_picture.id do
        Activities.update_calendar_picture(calendar_picture, params)
      else
        Activities.create_calendar_picture(params)
      end

    case result do
      {:ok, saved} ->
        case consume_image_data(saved, socket) do
          {:ok, _saved} ->
            {:noreply,
             socket
             |> put_flash(:info, "Calendar picture saved successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp consume_image_data(calendar_picture, socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      Activities.update_calendar_picture_image(calendar_picture, %{
        "image" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, saved}] -> {:ok, saved}
      _other -> {:ok, calendar_picture}
    end
  end
end
