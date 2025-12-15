defmodule PearlWeb.UserRegistrationLive do
  use PearlWeb, :live_view

  alias Pearl.Accounts
  alias Pearl.Accounts.User

  import PearlWeb.RegistrationComponents
  import PearlWeb.CoreComponents

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    default_ticket_id = :general
    selected_ticket = get_ticket_config(default_ticket_id)

    {:ok,
     socket
     |> assign(trigger_submit: false, check_errors: false)
     |> assign_form(changeset)
     |> assign(:step, 1)
     |> assign(:total_price, selected_ticket.price)
     |> assign(:selected_ticket, selected_ticket)
     |> assign(:current_user, nil)
     |> assign(:registrations_open?, true)
     |> assign(:pages, [])}
  end

  defp get_ticket_config(id) do
    # Com os tickets o Enrico deve fazer isto mais seamless no futuro
    tickets = %{
      general: %{
        id: :general,
        name: "Passe Geral",
        price: "XX,00",
        # Ícones e Cores MAybe fazer isto mais "simples" era melhor
        sidebar_icons: [
          %{icon: "hero-ticket", bg: "#FF5A87", rounded: "rounded-l-md"},
          %{icon: "hero-cake", bg: "#D9B568", rounded: ""},
          %{icon: "hero-sparkles", bg: "#A3C982", rounded: ""},
          %{icon: "hero-home", bg: "#8AB5C9", rounded: "rounded-r-md"},
          %{icon: "hero-star", bg: "#8FA3AD", rounded: "ml-1 rounded-[50%]"}
        ],
        # Lista de Benefícios Texto e Cor do certinho
        benefits: [
          %{text: "Entrada nos 4 dias do evento", color: "text-[#FF5A87]"},
          %{text: "Acesso a todas as atividades", color: "text-[#FF5A87]"},
          %{text: "Coffee Break de manhã e de tarde", color: "text-[#D9B568]"},
          %{text: "Almoço e Jantar incluídos", color: "text-[#A3C982]"},
          %{text: "3 noites de alojamento", color: "text-[#8AB5C9]"},
          %{text: "Transporte alojamento-evento", color: "text-[#8AB5C9]"},
          %{text: "Pequeno almoço", color: "text-[#8AB5C9]"}
        ]
      }

      # depois adciona-se mais aqui
    }

    Map.get(tickets, id, tickets.general)
  end

  defp get_initials(name) do
    case String.split(name || "", " ", trim: true) do
      [] -> nil
      [single] -> String.slice(single, 0, 1)
      names -> "#{String.first(List.first(names))}#{String.first(List.last(names))}"
    end
  end

  def handle_event("next_step", params, socket) do
    user_params = params["user"] || %{}

    changeset =
      socket.assigns.form.source
      |> User.registration_changeset(user_params)

    new_step = socket.assigns.step + 1
    {:noreply, socket |> assign(:step, new_step) |> assign_form(changeset)}
  end

  def handle_event("prev_step", _, socket) do
    new_step = max(1, socket.assigns.step - 1)
    {:noreply, assign(socket, step: new_step)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_attendee_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def step_header(1), do: "Bilhete Geral"
  def step_header(2), do: "Ótimo! Agora precisamos de alguns dados pessoais teus."
  def step_header(3), do: "Precauções e Alergias"
  def step_header(4), do: "Informações Adicionais"
  def step_header(5), do: "Já temos tudo."
  def step_header(_), do: ""

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: "user"))
  end
end
