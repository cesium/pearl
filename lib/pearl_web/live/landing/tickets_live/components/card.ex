defmodule PearlWeb.Landing.TicketsLive.Components.Card do
  @moduledoc """
  Tickets component.
  """
  use PearlWeb, :component
  alias Pearl.Tickets
  import PearlWeb.Components.Button

  defp button_state(%{type: :activity} = ticket_type, user_ticket), do: activity_button_state(ticket_type, user_ticket)
  defp button_state(%{type: :event} = ticket_type, user_ticket), do: event_button_state(ticket_type, user_ticket)

  defp activity_button_state(_ticket_type, nil), do: {:disabled, "Precisas de um passe geral"}
  defp activity_button_state(_ticket_type, user_ticket) when not Tickets.paid?(user_ticket), do: {:disabled, "Precisas de um passe geral"}
  defp activity_button_state(_ticket_type, %{ticket_type: %{type: :event}}), do: :enabled
  defp activity_button_state(_ticket_type, _), do: {:disabled, "Precisas de um passe geral"}

  defp event_button_state(_ticket_type, nil), do: :enabled
  defp event_button_state(_ticket_type, user_ticket) when not Tickets.paid?(user_ticket), do: :enabled
  defp event_button_state(ticket_type, %{ticket_type: %{type: :event, priority: user_priority}} = user_ticket) when Tickets.paid?(user_ticket) do
    cond do
      user_priority >= ticket_type.priority -> {:disabled, "Já tens um bilhete igual ou melhor"}
      user_priority < ticket_type.priority -> {:disabled, "Para upgrades contacta a equipa ENEI"}
    end
  end
  defp event_button_state(_ticket_type, _), do: :enabled

  def card(assigns) do
    assigns =
      assign(assigns, :button_state, button_state(assigns.ticket_type, assigns.user_ticket))

    ~H"""
    <div
      class="w-full min-h-[476px] h-full p-0.5"
      style="background: linear-gradient(to bottom right, rgba(0, 0, 0, 0.1) 0%, rgba(0, 0, 0, 0.05) 10%, transparent 60%);"
    >
      <div class="w-full min-h-[476px] h-full flex flex-col gap-5 justify-between bg-white overflow-hidden p-7 border-dark/20">
        <div class="flex flex-col gap-8">
          <div class="flex flex-wrap">
            <%= for {perk, i} <- Enum.with_index(@ticket_type.perks) do %>
              <.live_component
                module={PearlWeb.Checkout.Components.PrettyIcon}
                id={"perk-icon-#{@ticket_type.id}-#{i}"}
                perk={perk}
              />
            <% end %>
          </div>
          <div class="flex flex-col gap-3">
            <span class="text-black text-3xl font-extrabold">{@ticket_type.name}</span>
            <div class="flex flex-col gap-3">
              <div :for={perk <- @ticket_type.perks} class="flex items-start justify-start gap-2">
                <.icon name="hero-check" class="min-w-6 min-h-6" />
                <span class="text-black text-lg">{perk.description}</span>
              </div>
            </div>
          </div>
        </div>
        <div class="flex flex-col gap-2">
          <div class="flex gap-4 items-center justify-start">
            <span class="text-black text-4xl font-extrabold">
              {@ticket_type.price
              |> Float.round(2)
              |> :erlang.float_to_binary(decimals: 2)
              |> String.replace(".", ",")}€
            </span>
            <div>
              <.primary_button
                phx-value-ticket_type_id={@ticket_type.id}
                phx-value-type={@ticket_type.type}
                phx-click={if @button_state == :enabled, do: "select_ticket"}
                disabled={@button_state != :enabled}
                class={"size-16 rounded-none cursor-pointer #{if @button_state == :enabled, do: "bg-primary hover:bg-primary/90", else: "bg-dark/20 cursor-not-allowed"}"}
                small
              />
            </div>
          </div>
          <p :if={@button_state != :enabled} class="text-dark/50 text-sm">
            {elem(@button_state, 1)}
          </p>
        </div>
      </div>
    </div>
    """
  end
end
