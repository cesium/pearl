defmodule PearlWeb.ChallengeLive.FormComponent do
  use PearlWeb, :live_component

  alias Pearl.Challenges
  alias Pearl.Challenges.Challenge
  alias Pearl.Uploaders
  import PearlWeb.Components.{Forms, Button, ImageUploader}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          {gettext("The Challenges attendee participate in order to win prizes.")}
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="challenge-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.field field={@form[:name]} type="text" label="Name" required />
        <div class="grid grid-cols-3 space-x-4">
          <.field field={@form[:type]} type="select" options={type_options()} label="Type" required />
          <.field field={@form[:date]} type="date" label="Date" />
        </div>
        <.field
          field={@form[:description]}
          type="textarea"
          label="Description (supports markdown)"
          required
        />

        <div class="space-y-2">
          <.field_label>Challenge Image</.field_label>
          <.image_uploader
            class="h-80"
            image_class="h-80"
            icon="hero-trophy"
            upload={@uploads.image}
            image={Uploaders.Challenge.url({@challenge.image, @challenge}, :original, signed: true)}
          />
        </div>

        <h3 class="font-semibold leading-8">{gettext("Prizes")}</h3>

        <div class="max-h-40 overflow-y-scroll">
          <.inputs_for :let={prizes_form} field={@form[:prizes]}>
            <input type="hidden" name="challenge[prizes_sort][]" value={prizes_form.index} />
            <div class="grid grid-cols-11 space-x-4">
              <.field
                field={prizes_form[:prize_id]}
                type="select"
                options={prize_options(@prizes)}
                label="Prize"
                wrapper_class="w-full col-span-5"
                required
              />
              <.field
                field={prizes_form[:place]}
                type="number"
                label="Place"
                wrapper_class="col-span-5"
                required
              />
              <button
                type="button"
                name="challenge[prizes_drop][]"
                value={prizes_form.index}
                phx-click={JS.dispatch("change")}
                class="flex items-center justify-end"
              >
                <.icon name="hero-trash" class="w-6 h-6" />
              </button>
            </div>
          </.inputs_for>
        </div>
        <input type="hidden" name="challenge[prizes_drop][]" />

        <:actions>
          <button
            type="button"
            name="challenge[prizes_sort][]"
            value="new"
            phx-click={JS.dispatch("change")}
            class="phx-submit-loading:opacity-75 rounded-lg bg-dark text-light dark:bg-light dark:text-dark hover:bg-darkShade dark:hover:bg-lightShade/95 py-2 px-3 text-sm font-semibold leading-6 transition-colors "
          >
            {gettext("New Prize")}
          </button>

          <.backoffice_button phx-disable-with="Saving...">Save Challenge</.backoffice_button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:image,
       accept: Challenge.extension_whitelist(),
       max_entries: 1
     )}
  end

  @impl true
  def update(%{challenge: challenge} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Challenges.change_challenge(challenge))
     end)}
  end

  @impl true
  def handle_event("validate", %{"challenge" => challenge_params}, socket) do
    changeset = Challenges.change_challenge(socket.assigns.challenge, challenge_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"challenge" => challenge_params}, socket) do
    save_challenge(socket, socket.assigns.action, challenge_params)
  end

  defp save_challenge(socket, :edit, challenge_params) do
    case Challenges.update_challenge(socket.assigns.challenge, challenge_params) do
      {:ok, challenge} ->
        case consume_image_data(challenge, socket) do
          {:ok, _challenge} ->
            {:noreply,
             socket
             |> put_flash(:info, "Desafio atualizado com sucesso")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_challenge(socket, :new, challenge_params) do
    case Challenges.create_challenge(challenge_params) do
      {:ok, challenge} ->
        case consume_image_data(challenge, socket) do
          {:ok, _challenge} ->
            {:noreply,
             socket
             |> put_flash(:info, "Desafio criado com sucesso")
             |> push_patch(to: socket.assigns.patch)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp type_options do
    Enum.map(Challenge.challenge_types(), fn st ->
      {Atom.to_string(st) |> String.capitalize(), st}
    end)
  end

  defp prize_options(prizes) do
    Enum.map(prizes, &{&1.name, &1.id})
  end

  defp consume_image_data(challenge, socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      Challenges.update_challenge_image(challenge, %{
        "image" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, challenge}] ->
        {:ok, challenge}

      _errors ->
        {:ok, challenge}
    end
  end
end
