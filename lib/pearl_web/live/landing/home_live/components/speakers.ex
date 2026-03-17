defmodule PearlWeb.Landing.HomeLive.Components.Speakers do
  @moduledoc false
  use PearlWeb, :component
  alias Pearl.Activities.Speaker
  alias Pearl.Uploaders
  import PearlWeb.Components.Button
  attr :speakers, :list, required: true
  attr :selected_speaker, :map, default: nil
  attr :selected_activity, :map, default: nil
  attr :on_select, :string, default: "select_speaker"

  def speakers(assigns) do
    ~H"""
    <div :if={@speakers} class="flex flex-col bg-white gap-7.5">
      <div
        class="relative w-full overflow-hidden transition-colors duration-300 ease-in-out bg-primary text-light dynamic-gradient-bg"
        style={
          bg_style(@selected_speaker && Speaker.accent_color_rgb(@selected_speaker.accent_color))
        }
      >
        <div class="block md:hidden">
          <.mobile_layout
            speakers={@speakers}
            selected_speaker={@selected_speaker}
            selected_activity={@selected_activity}
            on_select={@on_select}
          />
        </div>
        <div class="hidden md:flex h-220 w-full pl-7 pt-7">
          <.desktop_layout
            speakers={@speakers}
            selected_speaker={@selected_speaker}
            selected_activity={@selected_activity}
            on_select={@on_select}
          />
        </div>
      </div>
      <.navigate_button
        navigate="/speakers"
        class="hidden md:flex relative z-40 mx-auto max-w-70 text-lg"
        title="conhece os oradores"
      />
    </div>
    """
  end

  defp mobile_layout(assigns) do
    ~H"""
    <div class="flex flex-col h-fit overflow-hidden backdrop-blur-2xl">
      <div class="py-6 shrink-0 relative">
        <.speaker_image
          speaker={@selected_speaker}
          class="absolute bottom-0 blur-xl left-0 w-full z-0  scale-y-[-1] opacity-90"
        />
        <div
          :if={@selected_speaker && @selected_speaker.picture}
          class="absolute inset-0 z-10 pointer-events-none"
          style={
            overlay_style(
              :top,
              @selected_speaker && Speaker.accent_color_rgb(@selected_speaker.accent_color)
            )
          }
        />
        <div class="flex flex-col items-center justify-center relative z-20 px-6">
          <.header_text class="relative" />
        </div>
      </div>
      <div class="relative w-full aspect-square object-cover shrink-0 overflow-hidden">
        <div class="absolute inset-0 w-full h-full">
          <.speaker_image
            speaker={@selected_speaker}
            class="w-full h-full object-cover transition-transform duration-700 ease-out"
          />
          <div
            :if={@selected_speaker && @selected_speaker.picture}
            class="absolute inset-0 pointer-events-none"
            style={
              overlay_style(
                :image,
                @selected_speaker && Speaker.accent_color_rgb(@selected_speaker.accent_color)
              )
            }
          >
          </div>
        </div>
        <div class="absolute bottom-0 left-0 w-full z-20 flex flex-col justify-end h-2/3">
          <div class="overflow-hidden max-h-full [scrollbar-width:none] [-ms-overflow-style:none] [&::-webkit-scrollbar]:hidden mask-[linear-gradient(to_bottom,transparent,black_20%)]">
            <.speaker_list
              speakers={@speakers}
              selected_speaker={@selected_speaker}
              on_select={@on_select}
              layout_mode={:mobile}
            />
          </div>
        </div>
      </div>
      <div class="flex flex-col items-center justify-start px-6 grow relative">
        <.info_card
          activity={@selected_activity}
          speaker={@selected_speaker}
          class="relative z-40"
        />
        <div class="flex flex-1 items-end justify-center relative z-40 pt-3.5 pb-7.5">
          <.navigate_button
            navigate="/speakers"
            class="z-40 mx-auto max-w-70 text-lg"
            title="conhece os oradores"
          />
        </div>
        <.speaker_image
          speaker={@selected_speaker}
          class="absolute blur-xl scale-y-[-1] z-0 top-0 w-full opacity-90"
        />
        <div
          :if={@selected_speaker && @selected_speaker.picture}
          class="absolute inset-0 z-10 pointer-events-none"
          style={
            overlay_style(
              :bottom,
              @selected_speaker && Speaker.accent_color_rgb(@selected_speaker.accent_color)
            )
          }
        />
      </div>
    </div>
    """
  end

  defp desktop_layout(assigns) do
    ~H"""
    <div class="flex flex-row w-full h-full justify-between items-end relative">
      <div class="flex flex-col h-full w-1/2 justify-between relative z-20">
        <.header_text class="mb-8" />
        <div class="">
          <.speaker_list
            speakers={@speakers}
            selected_speaker={@selected_speaker}
            on_select={@on_select}
            layout_mode={:desktop}
          />
        </div>
      </div>
      <div class="flex flex-col h-full w-full items-end justify-end z-10">
        <div class="absolute bottom-22 -translate-x-1/2 z-30" style="left: calc(1/2 * 100% - 28px)">
          <.info_card
            activity={@selected_activity}
            speaker={@selected_speaker}
            class="bg-background-muted/80 backdrop-blur-sm shadow-xl min-w-[300px]"
          />
        </div>
        <div class="absolute bottom-0 right-0 lg:h-[60%] xl:h-[70%] 2xl:h-[80%] p-0 flex items-end justify-end overflow-hidden pointer-events-none select-none">
          <.speaker_image
            speaker={@selected_speaker}
            class="size-full blur-xl mask-[radial-gradient(ellipse_at_bottom_left,black_20%,transparent_70%)] scale-x-[-1] opacity-50"
          /> <.speaker_image speaker={@selected_speaker} class="size-full" />
        </div>
      </div>
    </div>
    """
  end

  defp header_text(assigns) do
    ~H"""
    <div class={["flex flex-col space-y-2 lg:space-y-4", Map.get(assigns, :class, "")]}>
      <p class="text-3xl md:text-5xl font-bold leading-tight">
        Trazemos um elenco de estrelas
      </p>
      <p class="text-sm md:text-xl opacity-90 font-medium max-w-xl">
        Conhece os oradores que te trarão as palestras incríveis que temos preparadas para ti e sabe mais sobre quem são.
      </p>
    </div>
    """
  end

  defp speaker_list(assigns) do
    ~H"""
    <div
      class="
        relative
        z-10
        pt-10
        pb-10
        md:pb-50
        lg:py-10
        lg:pb-10
        max-h-100
        w-full
        overflow-hidden
        md:overflow-y-auto
        [scrollbar-width:none]
        [-ms-overflow-style:none]
        [&::-webkit-scrollbar]:hidden
        mask-[linear-gradient(to_bottom,transparent,black_15%,black_85%,transparent)]
      "
      id={"speaker-list-#{@layout_mode}"}
      phx-hook="SpeakerScroll"
    >
      <div
        :for={%{speaker: speaker, activity: activity} <- @speakers}
        id={"speaker-#{@layout_mode}-#{speaker.id}"}
        phx-click={@on_select}
        phx-value-speaker-id={speaker.id}
        class={[
          item_style(@layout_mode, @selected_speaker, speaker),
          "p-2 pl-5 text-5.5 md:text-[38px] hover:font-bold hover:scale-105 hover:ml-8 cursor-pointer transition-all duration-200 overflow-hidden"
        ]}
      >
        {speaker.name}
      </div>
    </div>
    """
  end

  defp speaker_image(assigns) do
    ~H"""
    <img
      :if={@speaker && @speaker.picture}
      src={speaker_image_url(@speaker)}
      class={[@class, "animate-[fade_in_0.5s_ease-out]"]}
    />
    """
  end

  defp info_card(assigns) do
    ~H"""
    <div
      :if={@speaker}
      class={[
        "rounded-[40px] md:rounded-full px-6 py-6 min-h-2 flex flex-col items-center justify-center animate-[fade_in_0.5s_both] md:text-dark",
        @class
      ]}
    >
      <p class="text-sm md:text-base font-medium md:block text-center">
        <span class="font-extrabold">{@speaker.title}</span>
        <span>
          <span class="opacity-60 mx-1">na</span>
          <span class="font-extrabold">{@speaker.company}</span>
        </span>
      </p>
      <%= if @activity do %>
        <p class="text-xs mt-1 font-medium text-center">
          <span class="opacity-60">
            Poderás ver este orador
          </span>
          <span class="text-primary border-b-2 border-primary ml-1 text-base md:text-lg pb-0.5">
            {format_activity_time(@activity)}
          </span>
        </p>
      <% end %>
    </div>
    """
  end

  defp item_style(:mobile, sel_speaker, speaker) do
    base = "text-3xl sm:text-4xl md:text-5xl pl-1 "

    if sel_speaker && sel_speaker.id == speaker.id do
      base <> "font-black! scale-105! origin-left! font-bold"
    else
      base <> "opacity-80"
    end
  end

  defp item_style(:desktop, sel_speaker, speaker) do
    base = "text-3xl pl-5 hover:font-semibold hover:scale-105 hover:ml-8"

    if sel_speaker && sel_speaker.id == speaker.id do
      base <> " font-black! scale-120! ml-14!"
    else
      base <> " opacity-100"
    end
  end

  defp overlay_style(:top, %{"r" => r, "g" => g, "b" => b}),
    do:
      "background: linear-gradient(to bottom, rgba(#{r},#{g},#{b},1.0) 0%, rgba(#{r},#{g},#{b},0.65) 100%);"

  defp overlay_style(:bottom, %{"r" => r, "g" => g, "b" => b}),
    do:
      "background: linear-gradient(to top, rgba(#{r},#{g},#{b},1.0) 0%, rgba(#{r},#{g},#{b},0.65) 100%);"

  defp overlay_style(:image, %{"r" => r, "g" => g, "b" => b}),
    do: "background: rgba(#{r},#{g},#{b},0.2);"

  defp overlay_style(_pos, _), do: ""
  defp bg_style(%{"r" => r, "g" => g, "b" => b}), do: "--r: #{r}; --g: #{g}; --b: #{b};"
  defp bg_style(_), do: "--r: 26; --g: 26; --b: 46;"

  defp speaker_image_url(speaker) do
    if speaker.picture,
      do: Uploaders.Speaker.url({speaker.picture, speaker}, :original, signed: true),
      else: nil
  end

  defp format_activity_time(activity) do
    date = Map.get(activity, :date)
    time = Map.get(activity, :time_start)

    cond do
      date && time -> "dia #{date.day} às #{Calendar.strftime(time, "%Hh")}"
      time -> "às #{Calendar.strftime(time, "%Hh")}"
      date -> "dia #{date.day}"
      true -> ""
    end
  end
end
