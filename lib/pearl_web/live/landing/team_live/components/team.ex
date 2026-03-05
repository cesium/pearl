defmodule PearlWeb.Landing.TeamLive.Components.Team do
  @moduledoc """
  Team component.
  """
  use PearlWeb, :component

  import PearlWeb.Components.Dropdown

  attr :teams, :list, required: true
  attr :current_filter, :atom, required: true

  def team(assigns) do
    ~H"""
    <div class="space-y-7.5 md:space-y-14">
      <div
        :if={@teams != []}
        class="mx-auto hidden md:flex flex-wrap justify-center p-1 bg-white w-fit rounded-3xl lg:rounded-full"
      >
        <%= for {team, index} <- Enum.with_index(Enum.sort_by(@teams, & &1.priority)) do %>
          <button
            phx-click="add_filter"
            phx-value-filter={team.name}
            class={[
              if @current_filter == team.name do
                "font-semibold bg-primary/10 hover:opacity-70 transition-all duration-200 cursor-pointer"
              else
                "hover:scale-95 transition-all duration-300 cursor-pointer"
              end,
              "text-primary md:text-sm lg:text-base px-3 lg:px-4 py-3 rounded-3xl"
            ]}
          >
            {team.name} ({length(team.team_members)})
          </button>
        <% end %>
      </div>

      <div class="px-2">
        <.dropdown
          :if={@teams != []}
          placement="right"
          class="md:hidden! w-full rounded-3xl bg-white"
          trigger_class="w-full"
          menu_items_wrapper_class="w-full! sm:w-1/2! border border-black/10 bg-white/60! shadow-[0_1px_20px_rgba(0,0,0,0.05)] backdrop-blur-[17px]"
        >
          <:trigger_element>
            <div class="w-full px-4 py-3 flex items-center justify-between text-primary">
              <span>
                <%= if @current_filter == :all do %>
                  Todos ({Enum.sum(Enum.map(@teams, fn team -> length(team.team_members) end))})
                <% else %>
                  {@current_filter} ({length(
                    Enum.find(@teams, &(&1.name == @current_filter)).team_members
                  )})
                <% end %>
              </span>
              <.icon name="hero-chevron-down-solid" class="w-5 h-5 pearl-dropdown__chevron" />
            </div>
          </:trigger_element>

          <.dropdown_selectable_item
            phx-click="add_filter"
            phx-value-filter="all"
            active={@current_filter == :all}
          >
            <p class="group-hover:pl-1 transition-all duration-200">
              Todos ({Enum.sum(Enum.map(@teams, fn team -> length(team.team_members) end))})
            </p>
          </.dropdown_selectable_item>

          <%= for {team, index} <- Enum.with_index(Enum.sort_by(@teams, & &1.priority)) do %>
            <.dropdown_selectable_item
              phx-click="add_filter"
              phx-value-filter={team.name}
              active={@current_filter == team.name}
            >
              <p class="group-hover:pl-1 transition-all duration-200">
                {team.name} ({length(team.team_members)})
              </p>
            </.dropdown_selectable_item>
          <% end %>
        </.dropdown>
      </div>

      <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-7 gap-2.5 justify-items-center">
        <%= for {team, index} <- Enum.with_index(Enum.sort_by(@teams, & &1.priority)) do %>
          <%= if (@current_filter == team.name || @current_filter == :all) do %>
            <%= for member <- team.team_members do %>
              <.member_card member={member} team_name={team.name} team_color={team.color} />
            <% end %>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  defp member_card(assigns) do
    ~H"""
    <div class="w-full flex flex-col group hover:scale-95 hover:shadow-lg transition-all duration-200 bg-white">
      <div
        class="flex items-center justify-center aspect-square"
        style={"background-color: #{@team_color}"}
      >
        <img
          src={
            if @member.image,
              do: Uploaders.Member.url({@member.image, @member}, :original, signed: true),
              else: "/images/braga_door_white.svg"
          }
          alt={"#{@member.name}'s photo"}
          class={
            if @member.image do
              "w-full aspect-square object-cover"
            else
              "w-1/2 h-1/2 opacity-30"
            end
          }
        />
      </div>
      <div class="bg-white p-4">
        <p class="text-md font-semibold">{@member.name}</p>
        <div class="inline-flex gap-2 items-center">
          <div class="w-5 h-1.5 rounded-md" style={"background-color: #{@team_color}"} />
          <p>{@team_name}</p>
        </div>
      </div>
    </div>
    """
  end
end
