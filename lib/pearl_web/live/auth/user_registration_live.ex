defmodule PearlWeb.UserRegistrationLive do
  use PearlWeb, :checkout_view

  alias Pearl.Accounts
  alias Pearl.Accounts.User

  import PearlWeb.Components.Button
  import PearlWeb.CoreComponents

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    months = [
      {"Janeiro", 1},
      {"Fevereiro", 2},
      {"Março", 3},
      {"Abril", 4},
      {"Maio", 5},
      {"Junho", 6},
      {"Julho", 7},
      {"Agosto", 8},
      {"Setembro", 9},
      {"Outubro", 10},
      {"Novembro", 11},
      {"Dezembro", 12}
    ]

    current_year = Date.utc_today().year
    years = current_year..(current_year - 100)//-1

    days = 1..31

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
     |> assign(:months, months)
     |> assign(:years, years)
     |> assign(:days, days)}
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
         |> redirect(to: "/users/log_in")}

      {:error, :user, changeset, _} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
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
end
