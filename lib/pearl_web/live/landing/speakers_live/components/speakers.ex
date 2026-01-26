defmodule PearlWeb.Landing.SpeakersLive.Components.Speakers do
  @moduledoc """
  Speakers component.
  """
  use PearlWeb, :component

  alias Pearl.Activities
  alias Plug.Conn.Query

  attr :event_start_date, Date, required: true
  attr :event_end_date, Date, required: true
  attr :url, :string, required: true
  attr :params, :map, required: true

  def speakers(assigns) do
    ~H"""
    <div class="flex flex-col gap-8 relative select-none w-full">
      <div class="mb-20 2xl:mb-0">
        <div class="sticky top-12">
          <.schedule_day
            date={fetch_current_date_from_params(assigns.params) || assigns.event_start_date}
            url={@url}
            params={@params}
            event_start_date={@event_start_date}
            event_end_date={@event_end_date}
          />
        </div>
      </div>
      <div>
        <.schedule_table
          date={fetch_current_date_from_params(assigns.params) || assigns.event_start_date}
          selected_speaker_id={fetch_speaker_id_from_params(assigns.params)}
        />
      </div>
    </div>
    """
  end

  defp schedule_table(assigns) do
    ~H"""
    <div class="space-y-2">
      <%= for %{speaker: speaker, activity: activity} <- Activities.list_daily_speakers(@date) do %>
        <.speaker speaker={speaker} activity={activity} selected={speaker.id == @selected_speaker_id} />
      <% end %>
    </div>
    """
  end

  defp speaker(assigns) do
    ~H"""
    <div
      id={"sp-#{@speaker.id}-#{@activity.id}"}
      class="flex flex-col w-full md:flex-row px-5 md:px-0 bg-white text-dark"
    >
      <img
        alt={@speaker.name}
        width="150"
        height="150"
        class="select-none h-full"
        src={
          if @speaker.picture do
            Uploaders.Speaker.url({@speaker.picture, @speaker}, :original, signed: true)
          else
            "https://github.com/identicons/#{@speaker.name |> String.slice(0..2)}.png"
          end
        }
      />

      <div class="flex w-full flex-col gap-2 pt-4 pb-5 md:px-5 min-w-0">
        <div class="space-y-4 w-full min-w-0">
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

            <div class="flex items-start md:items-center text-primary gap-1 min-w-0">
              <.icon name="hero-calendar" class="w-5 h-5 mt-0.5 md:mt-0" />
              <p class="whitespace-normal sm:truncate w-full">
                {format_date(@activity.date, @activity.time_start, @activity.time_end)} - {@activity.title}
              </p>
            </div>
          </div>
        </div>

        <div
          id={"speaker-#{@speaker.id}-#{@activity.id}"}
          class="overflow-hidden relative"
        >
          <p>{@speaker.biography}</p>
          <div class="absolute bottom-0 left-0 bg-linear-to-t from-white to-transparent w-full h-full" />
        </div>

        <div>
          <button
            :if={@speaker.biography}
            class="select-none text-primary cursor-pointer hover:opacity-70 transition-opacity duration-300"
            phx-click={
              if @selected do
                JS.toggle(
                  to: "#speaker-#{@speaker.id}-#{@activity.id}",
                  in: {"", "opacity-100 max-h-48", "opacity-0 max-h-0"},
                  out: {"", "opacity-0 max-h-0", "opacity-100 max-h-48"}
                )
              else
                JS.toggle(
                  to: "#speaker-#{@speaker.id}-#{@activity.id}",
                  in: {"", "opacity-0 max-h-0", "opacity-100 max-h-48"},
                  out: {"", "opacity-100 max-h-48", "opacity-0 max-h-0"}
                )
              end
              |> JS.toggle(to: "#speaker-toggle-show-#{@speaker.id}-#{@activity.id}")
              |> JS.toggle(to: "#speaker-toggle-hide-#{@speaker.id}-#{@activity.id}")
            }
          >
            <.icon name={"hero-arrow-#{if @selected, do: "up", else: "down"}"} class="w-5 h-5" />
            ler mais
          </button>
        </div>
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

  defp schedule_day(assigns) do
    ~H"""
    <div class="block sm:w-full select-none justify-center">
      <div class="flex justify-between text-4xl xs:text-5xl sm:text-7xl lg:text-8xl xl:mx-20 xl:text-7xl">
        <div class="right relative flex items-center justify-center mt-[0.15em]">
          <.link
            :if={Date.compare(@date, @event_start_date) in [:gt]}
            class="cursor-pointer"
            patch={day_url(@url, @date, -1)}
          >
            <.left_arrow />
          </.link>
        </div>

        <div class="-mt-8 md:-mt-10">
          <h5 class="font-terminal uppercase text-2xl text-accent md:text-3xl">
            {gettext("Happening on")}
          </h5>
          <h2 class="font-terminal uppercase text-center">
            {@date |> Timex.format!("{D} {Mshort}")}
          </h2>
        </div>

        <div class="left relative flex items-center justify-center mt-[0.15em]">
          <.link
            :if={Date.compare(@date, @event_end_date) in [:lt]}
            class="cursor-pointer"
            patch={day_url(@url, @date, 1)}
          >
            <.right_arrow />
          </.link>
        </div>
      </div>

      <div class="text-left text-md mt-12 max-w-96 m-auto">
        <p>
          {gettext(
            "During this week, you have the opportunity to interact with many recognized speakers, national, international and notorious companies!"
          )}
        </p>
        <p class="mt-4">{gettext("You can get to know them better here.")}</p>
      </div>
    </div>
    """
  end

  defp right_arrow(assigns) do
    ~H"""
    <svg
      class="h-[0.8em] w-[0.8em] fill-transparent transition-all hover:fill-white"
      width="42"
      height="65"
      viewBox="0 0 42 65"
      xmlns="http://www.w3.org/2000/svg"
    >
      <g filter="url(#filter0_d)">
        <path
          d="M23.4299 28.0481L5.02799 7.62693L12.4568 0.932693L37.1704 28.3582L12.5527 55.8698L5.10057 49.2016L23.4311 28.7162L23.7304 28.3817L23.4299 28.0481Z"
          stroke="white"
        />
      </g>
      <defs>
        <filter
          id="filter0_d"
          x="0.309082"
          y="0.182373"
          width="41.5826"
          height="64.4078"
          filterUnits="userSpaceOnUse"
          color-interpolation-filters="sRGB"
        >
          <feFlood flood-opacity="0" result="BackgroundImageFix" />
          <feColorMatrix
            in="SourceAlpha"
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
          />
          <feOffset dy="4" />
          <feGaussianBlur stdDeviation="2" />
          <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0" />
          <feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow" />
          <feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow" result="shape" />
        </filter>
      </defs>
    </svg>
    """
  end

  defp left_arrow(assigns) do
    ~H"""
    <svg
      class="h-[0.8em] w-[0.8em] fill-transparent transition-all hover:fill-white"
      width="42"
      height="65"
      viewBox="0 0 42 65"
      xmlns="http://www.w3.org/2000/svg"
    >
      <g filter="url(#filter0_d)">
        <path
          d="M37.3861 49.2873L29.9456 55.9686L5.27991 28.5L29.9456 1.03139L37.3861 7.71264L19.0199 28.1659L18.7199 28.5L19.0199 28.8341L37.3861 49.2873Z"
          stroke="white"
        />
      </g>
      <defs>
        <filter
          id="filter0_d"
          x="0.60791"
          y="0.325317"
          width="41.4843"
          height="64.3494"
          filterUnits="userSpaceOnUse"
          color-interpolation-filters="sRGB"
        >
          <feFlood flood-opacity="0" result="BackgroundImageFix" />
          <feColorMatrix
            in="SourceAlpha"
            type="matrix"
            values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
          />
          <feOffset dy="4" />
          <feGaussianBlur stdDeviation="2" />
          <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0" />
          <feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow" />
          <feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow" result="shape" />
        </filter>
      </defs>
    </svg>
    """
  end

  defp fetch_current_date_from_params(params) do
    case Map.get(params, "date") do
      nil ->
        nil

      day ->
        case Date.from_iso8601(day) do
          {:ok, date} -> date
          _ -> nil
        end
    end
  end

  defp fetch_speaker_id_from_params(params) do
    Map.get(params, "speaker_id")
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

  defp day_url(url, current_day, shift) do
    query = %{"date" => Timex.shift(current_day, days: shift)}

    "#{url}?#{Query.encode(query)}"
  end

  defp format_time(time) do
    hour = if time.hour < 10, do: "0#{time.hour}", else: "#{time.hour}"
    minute = if time.minute < 10, do: "0#{time.minute}", else: "#{time.minute}"
    "#{hour}:#{minute}"
  end

  defp format_date(date, time_start, time_end) do
    "Dia #{date.day} ,#{format_time(time_start)}-#{format_time(time_end)}"
  end
end
