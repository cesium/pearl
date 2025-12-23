defmodule PearlWeb.Landing.TeamLive.Components.Team do
  @moduledoc """
  Team component.
  """
  use PearlWeb, :component

  attr :teams, :list, required: true
  attr :current_filter, :atom, required: true

  def team(assigns) do
    ~H"""
    <div class="space-y-14">
      <div class="mx-auto flex flex-wrap justify-center p-1 bg-white w-fit rounded-3xl lg:rounded-full gap-2 lg:gap-8">
        <%= for {team, index} <- Enum.with_index(Enum.sort_by(@teams, & &1.priority)) do %>
          <button
            phx-click="add_filter"
            phx-value-filter={team.name}
            class={[
              if @current_filter == team.name do
                "font-semibold bg-primary/10 hover:opacity-70 transition-all duration-200 cursor-pointer"
              else
                "hover:scale-95 transition-all duration-300 cursor-pointer"
              end, "text-primary px-4 py-3 rounded-3xl"]
            }
          >
            {team.name} ({length(team.team_members)})
          </button>
        <% end %>
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
      <img
        src={
          if @member.image,
            do: Uploaders.Member.url({@member.image, @member}, :original, signed: true),
            else: "/images/team/placeholder.png"
        }
        alt={"#{@member.name}'s photo"}
        class="w-full aspect-square object-cover"
      />
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
