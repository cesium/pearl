defmodule PearlWeb.Landing.HomeLive.Components.Speakers do
  @moduledoc false
  use PearlWeb, :component
  alias Pearl.Uploaders

  attr :speakers, :list, required: true
  attr :selected_speaker, :map, default: nil
  attr :selected_activity, :map, default: nil
  attr :on_select, :string, default: "select_speaker"

  def speakers(assigns) do
    ~H"""
    <div class="md:mx-20 mx-0">
      <div
        class={[
          "relative w-full overflow-hidden transition-colors duration-300 ease-in-out",
          "bg-primary text-dark dynamic-gradient-bg",
          text_class(@selected_speaker && @selected_speaker.dominant_color)
        ]}
        style={bg_style(@selected_speaker && @selected_speaker.dominant_color)}
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
    </div>
    """
  end

  defp mobile_layout(assigns) do
    ~H"""
    <div class="flex flex-col px-6 pt-6 h-[80dvh] relative overflow-hidden">
      <div class="z-20 shrink-0 mb-4">
        <.header_text />
      </div>

      <div class="absolute scale-130 -top-35 left-0 w-full flex flex-col items-end justify-end pointer-events-none select-none">
        <div class="relative w-full">
          <.speaker_image
            speaker={@selected_speaker}
            class="w-full h-full scale-y-[-1]"
          />

          <.speaker_image
            speaker={@selected_speaker}
            class="w-full"
          />

          <.speaker_image
            speaker={@selected_speaker}
            class="w-full h-full scale-y-[-1]"
          />
          
    <!-- Top blur -->
          <div
            class="absolute top-0 left-0 right-0 h-[50%] backdrop-blur-3xl"
            style="mask-image: linear-gradient(to bottom, black 0%, black 50%, transparent 100%); -webkit-mask-image: linear-gradient(to bottom, black 0%, black 50%, transparent 100%);"
          >
          </div>
          
    <!-- Bottom blur -->
          <div
            class="absolute bottom-0 left-0 right-0 h-[40%] backdrop-blur-md"
            style="mask-image: linear-gradient(to top, black 0%, black 30%, transparent 100%); -webkit-mask-image: linear-gradient(to top, black 0%, black 30%, transparent 100%);"
          >
          </div>
        </div>
      </div>

      <div class="absolute bottom-0 h-[45%] left-0 z-10 min-h-0 overflow-y-auto pb-40 overflow-x-scroll [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
        <.speaker_list
          speakers={@speakers}
          selected_speaker={@selected_speaker}
          on_select={@on_select}
          layout_mode={:mobile}
        />
      </div>

      <div class="absolute z-30 bottom-8 left-0 right-0 px-4 flex justify-center">
        <.info_card
          activity={@selected_activity}
          speaker={@selected_speaker}
          class="w-[80%] shadow-xl bg-white/90 backdrop-blur-md"
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
        <div class="absolute bottom-30 -translate-x-1/2 z-30" style="left: calc(1/2 * 100% - 28px)">
          <.info_card
            :if={@selected_activity}
            activity={@selected_activity}
            speaker={@selected_speaker}
            class="bg-background-muted/80 backdrop-blur-sm shadow-xl min-w-[300px]"
          />
        </div>

        <div class="absolute bottom-0 right-0 h-[80%] p-0 flex items-end justify-center overflow-hidden pointer-events-none select-none">
          <.speaker_image
            speaker={@selected_speaker}
            class="size-full blur-xl mask-[radial-gradient(ellipse_at_bottom_right,black_20%,transparent_70%)] opacity-50"
          /> <.speaker_image speaker={@selected_speaker} class="size-full" />
        </div>
      </div>
    </div>
    """
  end

  defp header_text(assigns) do
    ~H"""
    <div class={["flex flex-col space-y-4", Map.get(assigns, :class, "")]}>
      <p class="text-4xl md:text-6xl font-bold leading-tight">
        Trazemos um elenco de estrelas
      </p>
      <p class="text-base md:text-xl opacity-90 font-medium max-w-xl">
        Conhece os oradores que te trarão as palestras incríveis que temos preparadas para ti.
      </p>
    </div>
    """
  end

  defp speaker_list(assigns) do
    ~H"""
    <div class="
          relative z-10
          py-10
          max-h-100
          w-2xl
          overflow-x-hidden
          overflow-y-auto
          [scrollbar-width:none]
          [-ms-overflow-style:none]
          [&::-webkit-scrollbar]:hidden
          mask-[linear-gradient(to_bottom,transparent,black_15%,black_85%,transparent)]
        ">
      <div
        :for={%{speaker: speaker, activity: activity} <- @speakers}
        id={"speaker-#{speaker.id}"}
        phx-click={@on_select}
        phx-value-speaker-id={speaker.id}
        class={[
          item_style(@layout_mode, @selected_speaker, speaker),
          "p-2 pl-5 text-5.5 md:text-3xl hover:font-bold hover:scale-105 hover:ml-8 hover:bg-white/10 cursor-pointer transition-all duration-200"
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
      :if={@activity}
      class={[
        "rounded-[40px] md:rounded-full px-6 py-4 flex flex-col items-center justify-center text-dark animate-[fade_in_0.5s_both]",
        @class
      ]}
    >
      <p class="text-sm md:text-base font-medium flex flex-col md:block text-center">
        <span class="font-extrabold">{@speaker.title}</span>
        <span>
          <span class="opacity-60 mx-1">na</span>
          <span class="font-extrabold">{@speaker.company}</span>
        </span>
      </p>

      <p class="text-xs mt-1 text-dark/60 font-medium text-center">
        <%!-- HELPPP< O QUE FACO AOS PRONOMESS (╯°□°)╯︵ ┻━┻ --%>
        Poderás ver o {first_name(@speaker.name)}
        <span class="text-primary border-b-2 border-primary ml-1 text-base md:text-lg pb-0.5">
          {format_activity_time(@activity)}
        </span>
      </p>
    </div>
    """
  end

  defp item_style(:mobile, sel_speaker, speaker) do
    base = "text-3xl pl-1 "

    if sel_speaker && sel_speaker.id == speaker.id do
      base <> "font-black! scale-105! origin-left!"
    else
      base <> "opacity-80"
    end
  end

  defp item_style(:desktop, sel_speaker, speaker) do
    base = "text-3xl pl-5 hover:font-bold hover:scale-105 hover:ml-8 hover:bg-white/10 "

    if sel_speaker && sel_speaker.id == speaker.id do
      base <> "font-black! scale-120! ml-14!"
    else
      base <> "opacity-100"
    end
  end

  defp text_class(color) do
    if light_color?(color), do: "text-dark", else: "text-light"
  end

  defp bg_style(%{"r" => r, "g" => g, "b" => b}), do: "--r: #{r}; --g: #{g}; --b: #{b};"
  defp bg_style(_), do: "--r: 26; --g: 26; --b: 46;"

  defp light_color?(%{"r" => r, "g" => g, "b" => b}) do
    (r * 299 + g * 587 + b * 114) / 1000 > 155
  end

  defp light_color?(_), do: false

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

  defp first_name(name), do: List.first(String.split(name, " "))
end
