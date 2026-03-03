defmodule PearlWeb.UserAuth.Components.UserProfileSettings do
  @moduledoc """
  Component responsible for the user profile settings (change name, handle, password, email, etc.)
  Can be used in the backoffice, app, or landing with different designs based on context.
  """

  use PearlWeb, :live_component

  alias Pearl.Accounts
  alias Pearl.Uploaders.UserPicture

  import PearlWeb.Components.Avatar
  import PearlWeb.Components.Forms
  import PearlWeb.Components.Button
  import PearlWeb.Components.ImageUploader

  @impl true
  def render(assigns) do
    case assigns.context do
      :landing -> render_landing(assigns)
      :app -> render_app(assigns)
      :backoffice -> render_backoffice(assigns)
    end
  end

  defp render_landing(assigns) do
    ~H"""
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <div class="lg:col-span-2">
        <.simple_form
          for={@profile_form}
          id="edit-profile-form"
          phx-change="validate_profile"
          phx-submit="update_profile"
          phx-target={@myself}
        >
          <div class="flex items-center gap-6 mb-6">
            <.image_uploader
              class="w-24 h-24"
              rounded
              upload={@uploads.picture}
              icon="hero-user"
              image={Uploaders.UserPicture.url({@user.picture, @user}, :original, signed: true)}
            >
              <:placeholder>
                <.avatar size={:lg} name={@user.name} />
              </:placeholder>
            </.image_uploader>

            <div class="flex-1">
              <h3 class="text-lg font-semibold">{@user.name}</h3>
              <p class="text-gray-600">@{@user.handle}</p>
            </div>
          </div>

          <div class="grid grid-cols-1 gap-4">
            <.input field={@profile_form[:name]} variant={:flushed} label="Name" required />
            <.input field={@profile_form[:handle]} variant={:flushed} label="Username" required />
            <.input
              field={@profile_form[:email]}
              variant={:flushed}
              label="Email"
              type="email"
              required
            />
            <.input
              field={@profile_form[:password]}
              variant={:flushed}
              label="New Password"
              type="password"
            />
            <.input
              field={@profile_form[:password_confirmation]}
              variant={:flushed}
              label="Confirm Password"
              type="password"
            />
            <.input
              field={@profile_form[:current_password]}
              variant={:flushed}
              value={@current_password}
              label="Current Password"
              type="password"
              required={@profile_form[:password].value not in [nil, ""]}
            />
          </div>
        </.simple_form>

        <.simple_form
          for={@new_user_session_form}
          id="new-user-session-form"
          action={"/users/log_in?_action=password_updated&_redirect_url=/settings&_notification_text=#{@notification_text}"}
          method="post"
          phx-trigger-action={@trigger_form_action}
          phx-target={@myself}
          class="hidden"
        >
          <.input field={@new_user_session_form[:email]} type="text" />
          <.input field={@new_user_session_form[:password]} type="password" />
        </.simple_form>
      </div>

      <div class="flex flex-col justify-between gap-6">
        <%= if @user.type == :attendee do %>
          <div class="bg-gray-50 rounded-lg p-6 border border-gray-200">
            <h4 class="font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <span>Referral Code</span>
            </h4>

            <%= if @user.attendee && @user.attendee.referral_id do %>
              <div class="space-y-2">
                <p class="text-sm text-gray-600">Your referral code:</p>
                <div class="flex items-center gap-2">
                  <code class="flex-1 bg-white px-3 py-2 rounded border border-gray-300 font-mono text-sm">
                    {@user.attendee.referral.code}
                  </code>
                </div>
                <input type="hidden" id="referral-code-value" value={@user.attendee.referral.code} />
                <p class="text-xs text-primary font-semibold">Active</p>
              </div>
            <% else %>
              <.simple_form
                for={@referral_form}
                id="referral-form"
                phx-submit="add_referral"
                phx-target={@myself}
              >
                <.input
                  field={@referral_form[:referral_code]}
                  type="text"
                  label="Enter Referral Code"
                  placeholder="ABC123"
                  class="mb-3"
                />
                <.primary_button type="submit" class="w-full" title="add code" />
              </.simple_form>
            <% end %>
          </div>
        <% end %>

        <div class="flex justify-end">
          <.primary_button
            type="submit"
            form="edit-profile-form"
            title="save changes"
          />
        </div>
      </div>
    </div>
    """
  end

  defp render_app(assigns) do
    ~H"""
    <div class="flex justify-center">
      <div class="flex flex-col gap-y-16 my-8 w-full max-w-md">
        <.simple_form
          for={@profile_form}
          id="edit-profile-form"
          phx-change="validate_profile"
          phx-submit="update_profile"
          phx-target={@myself}
        >
          <div class="flex justify-center w-full">
            <.image_uploader
              class="w-32 aspect-square"
              rounded
              upload={@uploads.picture}
              icon="hero-user"
              image={Uploaders.UserPicture.url({@user.picture, @user}, :original, signed: true)}
            >
              <:placeholder>
                <.avatar size={:xl} name={@user.name} />
              </:placeholder>
            </.image_uploader>
          </div>
          <div class="flex flex-col w-full">
            <div class="flex flex-col md:flex-row md:gap-x-8">
              <div>
                <.field
                  field={@profile_form[:name]}
                  type="text"
                  label="Name"
                  required
                  class="bg-blue-900/10! text-white! border-white!"
                  label_class="text-white!"
                />

                <.field
                  field={@profile_form[:handle]}
                  type="text"
                  label="Username"
                  required
                  class="bg-blue-900/10! text-white! border-white!"
                  label_class="text-white!"
                />

                <.field
                  field={@profile_form[:email]}
                  type="text"
                  label="Email"
                  required
                  class="bg-blue-900/10! text-white! border-white!"
                  label_class="text-white!"
                />
              </div>

              <div>
                <.field
                  field={@profile_form[:password]}
                  type="password"
                  label="New password"
                  class="bg-blue-900/10! text-white! border-white!"
                  label_class="text-white!"
                />

                <.field
                  field={@profile_form[:password_confirmation]}
                  type="password"
                  label="Repeat New Password"
                  class="bg-blue-900/10! text-white! border-white!"
                  label_class="text-white!"
                />

                <.field
                  field={@profile_form[:current_password]}
                  value={@current_password}
                  type="password"
                  label="Current Password"
                  required={@profile_form[:password].value not in [nil, ""]}
                  class="bg-blue-900/10! text-white! border-white!"
                  label_class="text-white!"
                />
              </div>
            </div>

            <div class="w-full flex justify-center">
              <.action_button title="Save Profile" class="w-full" />
            </div>
          </div>
        </.simple_form>

        <.simple_form
          for={@new_user_session_form}
          id="new-user-session-form"
          action={"/users/log_in?_action=password_updated&_redirect_url=/#{@base_path}/profile_settings&_notification_text=#{@notification_text}"}
          method="post"
          phx-trigger-action={@trigger_form_action}
          phx-target={@myself}
          class="hidden"
        >
          <.field
            field={@new_user_session_form[:email]}
            type="text"
            label="Email"
            required
            label_class="text-white!"
          />

          <.field
            field={@new_user_session_form[:password]}
            type="password"
            label="New password"
            label_class="text-white!"
          />
        </.simple_form>
      </div>
    </div>
    """
  end

  defp render_backoffice(assigns) do
    ~H"""
    <div class="flex justify-center">
      <div class="flex flex-col gap-y-16 my-8 w-full max-w-md">
        <.simple_form
          for={@profile_form}
          id="edit-profile-form"
          phx-change="validate_profile"
          phx-submit="update_profile"
          phx-target={@myself}
        >
          <div class="flex justify-center w-full">
            <.image_uploader
              class="w-32 aspect-square"
              rounded
              upload={@uploads.picture}
              icon="hero-user"
              image={Uploaders.UserPicture.url({@user.picture, @user}, :original, signed: true)}
            >
              <:placeholder>
                <.avatar size={:xl} name={@user.name} />
              </:placeholder>
            </.image_uploader>
          </div>
          <div class="flex flex-col w-full">
            <div class="flex flex-col md:flex-row md:gap-x-8">
              <div>
                <.field
                  field={@profile_form[:name]}
                  type="text"
                  label="Name"
                  required
                />

                <.field
                  field={@profile_form[:handle]}
                  type="text"
                  label="Username"
                  required
                />

                <.field
                  field={@profile_form[:email]}
                  type="text"
                  label="Email"
                  required
                />
              </div>

              <div>
                <.field
                  field={@profile_form[:password]}
                  type="password"
                  label="New password"
                />

                <.field
                  field={@profile_form[:password_confirmation]}
                  type="password"
                  label="Repeat New Password"
                />

                <.field
                  field={@profile_form[:current_password]}
                  value={@current_password}
                  type="password"
                  label="Current Password"
                  required={@profile_form[:password].value not in [nil, ""]}
                />
              </div>
            </div>

            <div class="w-full flex justify-center">
              <.backoffice_button class="w-full">
                Save Profile
              </.backoffice_button>
            </div>
          </div>
        </.simple_form>

        <.simple_form
          for={@new_user_session_form}
          id="new-user-session-form"
          action={"/users/log_in?_action=password_updated&_redirect_url=/dashboard/profile_settings&_notification_text=#{@notification_text}"}
          method="post"
          phx-trigger-action={@trigger_form_action}
          phx-target={@myself}
          class="hidden"
        >
          <.field
            field={@new_user_session_form[:email]}
            type="text"
            label="Email"
            required
          />

          <.field
            field={@new_user_session_form[:password]}
            type="password"
            label="New password"
          />
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    user = assigns.user

    user =
      if user.type == :attendee do
        Pearl.Repo.preload(user, attendee: :referral)
      else
        user
      end

    profile_changeset = Accounts.change_user_profile(user)
    new_user_session_changeset = Accounts.change_user_password(user)

    context = Map.get(assigns, :context, get_context_by_user_type(user))
    base_path = get_base_path_by_user_type(user)
    referral_code = Map.get(assigns, :referral_code, "")

    socket =
      socket
      |> assign(user: user)
      |> assign(:profile_form, to_form(profile_changeset))
      |> assign(new_user_session_form: to_form(new_user_session_changeset))
      |> assign(current_password: nil)
      |> assign(trigger_form_action: false)
      |> assign(notification_text: nil)
      |> assign(context: context)
      |> assign(base_path: base_path)
      |> allow_upload(:picture,
        accept: UserPicture.extension_whitelist(),
        max_entries: 1
      )

    socket =
      if user.type == :attendee do
        referral_changeset = Accounts.change_user_referral(user, %{referral_code: referral_code})
        assign(socket, referral_form: to_form(referral_changeset, as: :user))
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_profile", params, socket) do
    %{"user" => user_params} = params
    %{"current_password" => current_password} = user_params
    user = socket.assigns.user

    changeset = Accounts.change_user_profile(user, user_params)

    new_user_session_changeset =
      Accounts.change_user_password(user, %{
        email: user.email,
        password: Map.get(user_params, "password_confirmation", "")
      })

    {:noreply,
     socket
     |> assign(profile_form: to_form(changeset, action: :validate))
     |> assign(new_user_session_form: to_form(new_user_session_changeset))
     |> assign(current_password: current_password)}
  end

  @impl true
  def handle_event("update_profile", params, socket) do
    %{"user" => user_params} = params
    %{"current_password" => current_password} = user_params
    user = socket.assigns.user

    email_changed? = user.email != user_params["email"]

    password_changed? =
      user_params["password"] != nil && String.trim(user_params["password"]) != ""

    case Accounts.update_user_profile(user, current_password, user_params) do
      {:ok, applied_user} ->
        case consume_picture_data(applied_user, socket) do
          {:ok, final_user} ->
            if email_changed? do
              Accounts.deliver_user_update_email_instructions(
                applied_user,
                user.email,
                &url(~p"/users/settings/confirm_email/#{&1}")
              )
            end

            info =
              "Profile updated successfully." <>
                if email_changed? do
                  " A link to confirm your email change has been sent to the new address."
                else
                  ""
                end

            send(self(), {:update_current_user, final_user})
            send(self(), {:update_flash, {:info, info}})

            {:noreply,
             socket
             |> assign(profile_form: to_form(Accounts.change_user_profile(final_user)))
             |> assign(user: final_user)
             |> assign(current_password: nil)
             |> assign(trigger_form_action: password_changed?)
             |> assign(notification_text: info)}
        end

      {:error, changeset} ->
        {:noreply, assign(socket, profile_form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("add_referral", %{"user" => %{"referral_code" => code}}, socket) do
    user = socket.assigns.user

    case Accounts.add_referral_code(user, code) do
      {:ok, updated_user} ->
        send(self(), {:update_current_user, updated_user})
        send(self(), {:update_flash, {:info, "Referral code added successfully!"}})

        {:noreply,
         socket
         |> assign(user: updated_user)
         |> assign(referral_form: to_form(Accounts.change_user_referral(updated_user), as: :user))}

      {:error, changeset} ->
        send(self(), {:update_flash, {:error, "Invalid referral code"}})
        {:noreply, assign(socket, referral_form: to_form(changeset, as: :user))}
    end
  end

  defp consume_picture_data(user, socket) do
    consume_uploaded_entries(socket, :picture, fn %{path: path}, entry ->
      Accounts.update_user_picture(user, %{
        "picture" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [updated_user] -> {:ok, updated_user}
      _errors -> {:ok, user}
    end
  end

  defp get_context_by_user_type(user) do
    case user.type do
      :attendee -> :app
      :staff -> :backoffice
      :company -> :backoffice
    end
  end
end
