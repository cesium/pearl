defmodule PearlWeb.Landing.TicketsLive.Components.Card do
  @moduledoc """
  Tickets component.
  """
  use PearlWeb, :component
  import PearlWeb.Components.Button

  def card(assigns) do
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
              <div :for={perk <- @ticket_type.perks} class="flex gap-2">
                <img
                  src={~p"/images/check.svg"}
                  alt={gettext("Check")}
                  class="max-w-fit"
                />
                <span class="text-black text-lg">{perk.description}</span>
              </div>
            </div>
          </div>
        </div>
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
              phx-click="select_ticket"
              class="w-16 h-16 rounded-none bg-primary hover:bg-primary/90 cursor-pointer"
              small
            />
          </div>
        </div>
      </div>
    </div>
    """
  end
end
