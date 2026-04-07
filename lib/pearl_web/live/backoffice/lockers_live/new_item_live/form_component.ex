defmodule PearlWeb.Backoffice.LockersLive.NewItemLive.FormComponent do
  use PearlWeb, :live_component

  alias Pearl.Lockers
  alias Pearl.Lockers.LockerItem
  alias Pearl.Uploaders.LockerItems

  import PearlWeb.Components.{Forms, ImageUploader}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          {gettext("Add a new item to this locker.")}
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="locker-item-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div>
          <div class="flex flex-col">
            <.field field={@form[:name]} type="text" label="Name" required />
            <.field field={@form[:description]} type="textarea" label="Description" rows={2} />
          </div>

          <div class="w-full">
            <.field_label>{gettext("Item Picture")}</.field_label>
            <.image_uploader
              class="w-full h-60"
              image_class="h-60"
              upload={@uploads.picture}
              image={
                if @item.picture, do: LockerItems.url({@item.picture, @item}, :original, signed: true)
              }
              accept="image/*"
              capture="environment"
            />
          </div>
        </div>

        <:actions>
          <.backoffice_button phx-disable-with="Saving...">
            {gettext("Save Item")}
          </.backoffice_button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:item, %LockerItem{})
     |> allow_upload(:picture,
       accept: LockerItems.extension_whitelist(),
       max_entries: 1
     )}
  end

  @impl true
  def update(assigns, socket) do
    item = Map.get(assigns, :item, socket.assigns[:item] || %LockerItem{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:item, item)
     |> assign_new(:form, fn ->
       to_form(Lockers.change_locker_item(item), as: :locker_item)
     end)}
  end

  @impl true
  def handle_event("validate", %{"locker_item" => params}, socket) do
    changeset =
      socket.assigns.item
      |> Lockers.change_locker_item(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: :locker_item))}
  end

  def handle_event("save", %{"locker_item" => params}, socket) do
    locker_item_params = Map.put(params, "attendee_locker_id", socket.assigns.session_id)

    case Lockers.create_locker_item(locker_item_params) do
      {:ok, item} ->
        case consume_picture_data(item, socket) do
          {:ok, item} ->
            {:noreply,
             socket
             |> assign(:item, item)
             |> put_flash(:info, "Locker item created successfully")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :locker_item))}
    end
  end

  defp consume_picture_data(item, socket) do
    consume_uploaded_entries(socket, :picture, fn %{path: path}, entry ->
      Lockers.update_locker_item_picture(item, %{
        "picture" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, item}] ->
        {:ok, item}

      _errors ->
        {:ok, item}
    end
  end
end
