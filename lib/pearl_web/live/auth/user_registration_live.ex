defmodule PearlWeb.UserRegistrationLive do
  use PearlWeb, :checkout_view

  alias Pearl.Accounts
  alias Pearl.Accounts.User
  alias Pearl.Event

  import PearlWeb.Components.Button
  import PearlWeb.CoreComponents

  def mount(params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})
    referral_code = Map.get(params, "referral_code", "")

    {:ok,
     socket
     |> assign(trigger_submit: false, check_errors: false)
     |> assign_form(changeset)
     |> assign(:step, 1)
     |> assign(:current_user, nil)
     |> assign(:registrations_open?, true)
     |> assign(:universities, Pearl.Catalog.universities())
     |> assign(:cities, Pearl.Catalog.cities())
     |> assign(:pages, [])
     |> assign(:privacy_policy_exists, check_privacy_policy_exists())
     |> assign(:event_regulations_exists, check_event_regulations_exists())
     |> assign(:referral_code, referral_code)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_attendee_registration(%User{}, user_params)

    days_range = calculate_days_range(user_params["birth_date"])

    {:noreply,
     socket
     |> assign(:days, days_range)
     |> assign_form(Map.put(changeset, :action, :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_attendee_user(user_params) do
      {:ok, %{user: user}} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))

        changeset = Accounts.change_attendee_registration(user)

        {:noreply,
         socket
         |> assign(trigger_submit: true)
         |> assign_form(changeset)
         |> put_flash(:info, "Account successfully created")
         |> redirect(to: "/users/log_in")}

      {:error, :referral, reason, _} ->
        error_message =
          case reason do
            :invalid_referral -> "Invalid referral code"
            :inactive_referral -> "This referral code is inactive"
            _ -> "Could not apply referral code"
          end

        {:noreply,
         socket
         |> put_flash(:error, error_message)
         |> assign(check_errors: true)}

      {:error, :user, changeset, _} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: "user"))
  end

  defp calculate_days_range(%{"year" => y, "month" => m}) when y != "" and m != "" do
    year = String.to_integer(y)
    month = String.to_integer(m)

    case Date.new(year, month, 1) do
      {:ok, date} -> 1..Date.days_in_month(date)
      _ -> 1..31
    end
  end

  defp calculate_days_range(%{"month" => m}) when m != "" do
    month = String.to_integer(m)

    case Date.new(2024, month, 1) do
      {:ok, date} -> 1..Date.days_in_month(date)
      _ -> 1..31
    end
  end

  defp calculate_days_range(_), do: 1..31

  defp check_privacy_policy_exists,
    do: not is_nil(Event.get_faq_by_slug!("politica-de-privacidade"))

  defp check_event_regulations_exists, do: not is_nil(Event.get_faq_by_slug!("regulamento-geral"))
end
