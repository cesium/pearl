defmodule PearlWeb.App.LeaderboardLive.Components.Leaderboard do
  @moduledoc """
  Leaderboard component
  """

  use PearlWeb, :component

  import PearlWeb.Components.Avatar
  alias Pearl.Accounts.User

  attr :entries, :list, required: true
  attr :user_position, :any, required: true

  def leaderboard(assigns) do
    ~H"""
    <div class="w-full">
      <.leaderboard_top_3 entries={Enum.take(@entries, 3)} />
      <ul class="flex flex-col mt-6 w-full divide-y divide-light/5 bg-light/2 border border-light/5 rounded-xl">
        <.leaderboard_entry
          :for={entry <- Enum.drop(@entries, 3)}
          entry={entry}
          self={@user_position && entry.position == @user_position.position}
        />
        <.leaderboard_entry
          :if={
            not is_nil(@user_position) and
              not Enum.member?(Enum.map(@entries, fn e -> e.position end), @user_position.position)
          }
          entry={@user_position}
          self={true}
        />
      </ul>
    </div>
    """
  end

  defp leaderboard_top_3(assigns) do
    ~H"""
    <div class="flex flex-row justify-between max-w-xl mx-auto">
      <.leaderboard_top_person entry={Enum.at(@entries, 1)} pos={2} />
      <.leaderboard_top_person entry={Enum.at(@entries, 0)} winner={true} pos={1} />
      <.leaderboard_top_person entry={Enum.at(@entries, 2)} pos={3} />
    </div>
    """
  end

  attr :entry, :map, required: true
  attr :winner, :boolean, default: false
  attr :pos, :integer, required: true

  defp leaderboard_top_person(assigns) do
    ~H"""
    <%= if @entry do %>
      <div class={["flex flex-col w-full items-center mt-8 mb-4", @winner && "-translate-y-20"]}>
        <.icon
          :if={@winner}
          name="fa-crown fa-crown-solid"
          class="w-10 h-10 translate-y-4 text-accent"
        />
        <.avatar
          name={@entry.name}
          size={:xl}
          src={get_picture_url(@entry)}
          class="border-3 border-light shadow-[0_0_20px_2px] shadow-white/25 rounded-full"
          link={~p"/app/user/#{@entry.handle}"}
        />
        <span class="bg-light text-dark rounded-full px-2 -translate-y-4 select-none font-semibold border-light border-2">
          {@pos}
        </span>
        <p class="font-semibold truncate max-w-28 sm:max-w-full">{@entry.name}</p>
        <p class="font-semibold">
          {gettext("%{badges_count} badges", badges_count: @entry.badges)}
        </p>
      </div>
    <% end %>
    """
  end

  attr :entry, :map, required: true
  attr :self, :boolean, default: false

  defp leaderboard_entry(assigns) do
    ~H"""
    <li class={[
      "flex flex-row py-4 pl-3 pr-4 md:pl-7 md:pr-8 justify-between items-center text-white",
      @self && "bg-primary/20 rounded-b-xl"
    ]}>
      <div class="flex flex-row gap-4 items-center">
        <p class="font-bold text-center tabular-nums min-w-[3ch] shrink-0 leading-none">
          {@entry.position}
        </p>
        <.avatar
          name={@entry.name}
          size={:sm}
          class={"#{if @self do "bg-primary/10 border-2 border-primary/10" else "bg-light/5 border-2 border-light/5" end} rounded-full"}
          src={get_picture_url(@entry)}
          link={~p"/app/user/#{@entry.handle}"}
        />
        <div>
          <p class="font-medium truncate max-w-40">
            {@entry.name}
          </p>
          <p class="text-light/50 text-sm">@{@entry.handle}</p>
        </div>
      </div>

      <div>
        <p class="font-medium">
          {@entry.badges}
          <span class="hidden lg:inline">
            {gettext(" badges")}
          </span>
        </p>
      </div>
    </li>
    """
  end

  defp get_picture_url(%{picture: picture, user_id: user_id}) when not is_nil(picture) do
    user = %User{id: user_id, picture: picture}
    Uploaders.UserPicture.url({picture, user}, :original, signed: true)
  end

  defp get_picture_url(_entry), do: nil
end
