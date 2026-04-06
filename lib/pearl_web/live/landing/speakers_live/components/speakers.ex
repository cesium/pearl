defmodule PearlWeb.Landing.SpeakersLive.Components.Speakers do
  @moduledoc """
  Speakers component.
  """

  use PearlWeb, :component

  import PearlWeb.Components.Dropdown

  attr :event_start_date, Date, required: true
  attr :event_end_date, Date, required: true
  attr :speakers, :list, required: true
  attr :all_speakers, :list, required: true
  attr :current_filter, :atom, required: true
  attr :current_value, :atom, required: true

  def speakers(assigns) do
    ~H"""
    <div class="w-full flex flex-col gap-2.5 md:gap-10">
      <div class="w-full flex justify-between items-center">
        <.dropdown
          placement="right"
          class="w-fit p-2"
          trigger_class="w-full"
          menu_items_wrapper_class="w-full! border border-black/10 bg-white!"
        >
          <:trigger_element>
            <div class="w-full flex items-center gap-2 text-primary cursor-pointer">
              <.icon name="hero-bars-3-bottom-left" class="w-5 h-5" />
              <p>
                {gettext("opções de filtragem")}
              </p>
            </div>
          </:trigger_element>

          <%= for filter <- [:name, :activity_date] do %>
            <.dropdown_selectable_item
              phx-click="select-filter"
              phx-value-filter={filter}
              active={@current_filter == filter}
            >
              <p class="text-dark">
                {if filter == :name, do: gettext("Filtrar por nome"), else: gettext("Filtrar por dia")}
              </p>
            </.dropdown_selectable_item>
          <% end %>
        </.dropdown>

        <button
          type="button"
          phx-click="clear-filter"
          class="bg-primary p-2 hover:bg-primary/70 text-white transition-colors duration-200 cursor-pointer"
        >
          {gettext("limpar")}
        </button>
      </div>

      <div class="flex flex-col md:flex-row gap-7.5 md:gap-12.5 w-full">
        <.filter_form
          all_speakers={@all_speakers}
          event_start_date={@event_start_date}
          event_end_date={@event_end_date}
          current_filter={@current_filter}
          current_value={@current_value}
          id="speaker-filter"
        />
        <.schedule_table speakers={@speakers} />
      </div>
    </div>
    """
  end

  defp schedule_table(assigns) do
    ~H"""
    <div class="space-y-2 min-w-0 w-full">
      <%= for %{speaker: speaker, activities: activities} <- @speakers do %>
        <.speaker speaker={speaker} activities={activities} />
      <% end %>
    </div>
    """
  end

  attr :activities, :list, default: []
  attr :speaker, :map, default: nil

  defp speaker(assigns) do
    assigns = assign(assigns, :card_id, assigns.speaker.id)

    ~H"""
    <div
      id={"card-#{@card_id}"}
      class="flex flex-col w-full md:flex-row px-5 md:px-0 bg-white text-dark"
    >
      <img
        alt={@speaker.name}
        width="100"
        height="100"
        class="select-none sm:h-40 sm:w-40 md:h-52 md:w-52 lg:h-45 lg:w-45 object-cover aspect-square"
        src={
          if @speaker.picture do
            Uploaders.Speaker.url({@speaker.picture, @speaker}, :original, signed: true)
          else
            "https://github.com/identicons/#{@speaker.name |> String.slice(0..2)}.png"
          end
        }
      />

      <div class="flex w-full flex-col gap-2 py-4 md:px-5 min-w-0">
        <div class="space-y-2 w-full min-w-0">
          <div class="flex w-full justify-between items-center">
            <h2 class="font-semibold text-xl">{@speaker.name}</h2>
            <div class="flex gap-2 mb-1">
              <.social platform="github" profile={@speaker.socials.github} />
              <.social platform="linkedin" profile={@speaker.socials.linkedin} />
              <.social platform="website" profile={@speaker.socials.website} />
              <.social platform="x" profile={@speaker.socials.x} />
            </div>
          </div>

          <div class="flex flex-col lg:flex-row w-full gap-1 lg:gap-8 min-w-0">
            <p class="truncate lg:whitespace-nowrap lg:overflow-visible">
              {@speaker.title} <span class="text-dark/50">@</span> {@speaker.company}
            </p>

            <div :if={@activities != []} class="space-y-1 min-w-0">
              <%= for activity <- @activities do %>
                <div class="flex items-start md:items-center text-primary gap-1 min-w-0">
                  <.icon name="hero-calendar" class="w-5 h-5 mt-0.5 md:mt-0 shrink-0" />
                  <p class="whitespace-normal sm:truncate w-full">
                    {format_date(activity.date, activity.time_start, activity.time_end)} - {activity.title}
                  </p>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div
          class="overflow-hidden relative max-h-0 transition-all duration-300"
          id={"speaker-#{@card_id}"}
        >
          <p>{@speaker.biography}</p>
        </div>

        <button
          class="select-none flex text-primary cursor-pointer hover:opacity-70 transition-opacity duration-300 items-center gap-2"
          phx-click={
            JS.toggle_class("max-h-0", to: "#speaker-#{@card_id}")
            |> JS.toggle_class("max-h-fit", to: "#speaker-#{@card_id}")
            |> JS.toggle_class("hidden", to: "#arrow-down-#{@card_id}")
            |> JS.toggle_class("hidden", to: "#arrow-up-#{@card_id}")
            |> JS.toggle_class("hidden", to: "#show-more-#{@card_id}")
            |> JS.toggle_class("hidden", to: "#show-less-#{@card_id}")
            |> JS.toggle_class("opacity-0", to: "#fade-gradient-#{@card_id}")
          }
        >
          <.icon
            id={"arrow-down-#{@card_id}"}
            name="hero-arrow-down"
            class="w-5 h-5"
          />
          <.icon
            id={"arrow-up-#{@card_id}"}
            name="hero-arrow-up"
            class="w-5 h-5 hidden"
          />
          <span id={"show-more-#{@card_id}"}>{gettext("ler mais")}</span>
          <span id={"show-less-#{@card_id}"} class="hidden">
            {gettext("ler menos")}
          </span>
        </button>
      </div>
    </div>
    """
  end

  defp social(assigns) do
    ~H"""
    <.link
      :if={not is_nil(@profile)}
      href={social_media_link(@platform, @profile)}
      target="_blank"
    >
      <.icon
        name={social_media_icon(@platform)}
        class="h-5 w-5 text-dark/50 hover:text-primary transition-colors duration-300"
      />
    </.link>
    """
  end

  defp social_media_icon(social) do
    case social do
      "github" -> "fa-brand-github"
      "linkedin" -> "fa-brand-linkedin"
      "x" -> "fa-brand-x-twitter"
      "website" -> "hero-globe-alt"
    end
  end

  defp social_media_link(social, profile) do
    case social do
      "github" -> "https://github.com/#{profile}"
      "linkedin" -> "https://linkedin.com/in/#{profile}"
      "x" -> "https://x.com/#{profile}"
      "website" -> profile
    end
  end

  defp format_time(time) do
    hour = if time.hour < 10, do: "0#{time.hour}", else: "#{time.hour}"
    minute = if time.minute < 10, do: "0#{time.minute}", else: "#{time.minute}"
    "#{hour}:#{minute}"
  end

  defp format_date(date, time_start, time_end) do
    "Dia #{date.day}, #{format_time(time_start)}-#{format_time(time_end)}"
  end

  attr :id, :string, default: nil
  attr :all_speakers, :list, required: true
  attr :event_start_date, Date, required: true
  attr :event_end_date, Date, required: true
  attr :current_filter, :atom, required: true
  attr :current_value, :string, required: true

  def filter_form(assigns) do
    ~H"""
    <div class="flex flex-wrap md:flex-col">
      <%= for item <- get_filter_items(@all_speakers, @event_start_date, @event_end_date, @current_filter) do %>
        <button
          type="button"
          phx-value-activity-date={if @current_filter == :activity_date, do: item, else: nil}
          phx-value-name={if @current_filter == :name, do: item, else: nil}
          phx-click="update-filter"
          class={[
            "w-10 h-10 cursor-pointer",
            if(@current_value == to_string(item),
              do: "bg-primary text-white hover:bg-primary/50",
              else: "hover:bg-white/50 text-dark"
            )
          ]}
        >
          {if @current_filter == :name, do: item, else: item.day}
        </button>
      <% end %>
    </div>
    """
  end

  def get_filter_items(all_speakers, event_start_date, event_end_date, current_filter) do
    case current_filter do
      :name ->
        all_speakers
        |> Enum.map(&String.first(List.first(String.split(&1.speaker.name, " "))))
        |> Enum.uniq()
        |> Enum.sort()

      :activity_date ->
        Date.range(event_start_date, event_end_date)
    end
  end
end
