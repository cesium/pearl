defmodule PearlWeb.Landing.HomeLive.Components.Speakers do
  @moduledoc false
  use PearlWeb, :component

  import PearlWeb.Components.Button

  attr :speakers, :list, required: true
  attr :selected_speaker, :map, default: nil

  def speakers(assigns) do
    ~H"""
    <div class="relative -mx-8 lg:-mx-16 overflow-hidden min-h-screen">
      <div class="absolute inset-0 z-0">
        <div
          :if={@selected_speaker && @selected_speaker.picture}
          class="absolute inset-0 bg-cover bg-center"
          style={"background-image: url('#{Uploaders.Speaker.url({@selected_speaker.picture, @selected_speaker}, :original, signed: true)}');"}
        >
        </div>
        <div class="absolute inset-0 backdrop-blur-[150px] bg-olive/70"></div>
      </div>

      <div class="relative z-10 px-8 lg:px-16 py-16 h-screen flex flex-col">
        <div class="flex justify-between items-start mb-12">
          <div class="max-w-2xl">
            <h1 class="text-5xl font-terminal uppercase text-white mb-4 leading-tight tracking-wide">
              Trazemos oradores extraordinários
            </h1>
            <p class="text-white/80 text-base">
              Conhece os oradores que te trarão as palestras incríveis que temos preparadas para ti e sabe mais sobre quem são.
            </p>
          </div>
          <.link navigate={~p"/speakers"}>
            <.secondary_button
              title="conhece os oradores"
              icon="hero-arrow-right"
              icon_position="right"
              class="!bg-primary !text-white hover:!bg-primary/80 !rounded-none !text-base !w-70 !h-10 !px-8 !py-4 !font-medium"
            />
          </.link>
        </div>

        <div class="grid grid-cols-2 gap-0 relative flex-1 min-h-0">
          <div
            class="pr-12 overflow-y-auto relative speakers-scroll h-full"
            phx-hook="SpeakerScroll"
            id="speakers-scroll-container"
            style="max-height: calc(100vh - 200px);"
          >
            <div class="space-y-1 py-2" id="speakers-list-inner">
              <div
                :for={{id, speaker} <- @speakers}
                id={id}
                class={[
                  "py-3 px-4 rounded-md transition-all duration-300 cursor-pointer speaker-item",
                  if(speaker.selected,
                    do: "text-white font-bold text-xl bg-white/10",
                    else: "text-white/50 text-lg hover:text-white/80 font-normal"
                  )
                ]}
                data-speaker-id={speaker.id}
                phx-click={JS.push("select_speaker", value: %{id: speaker.id})}
              >
                {speaker.name}
              </div>
            </div>
          </div>

          <div class="absolute left-1/2 top-0 bottom-0 w-0.5 bg-white/30 transform -translate-x-1/2">
          </div>

          <div class="flex flex-col items-end justify-end">
            <div
              :if={@selected_speaker}
              class="absolute -bottom-16 -right-16 flex flex-col items-center py-24 px-24 bg-white/60"
              id="speaker-detail"
              phx-hook="FadeIn"
            >
              <div class="w-96 h-96 rounded-full overflow-hidden mb-24">
                <img
                  src={
                    if @selected_speaker.picture do
                      Uploaders.Speaker.url({@selected_speaker.picture, @selected_speaker}, :original,
                        signed: true
                      )
                    else
                      "https://github.com/identicons/#{@selected_speaker.name |> String.slice(0..2)}.png"
                    end
                  }
                  alt={@selected_speaker.name}
                  class="w-full h-full object-cover"
                />
              </div>

              <div class="text-center max-w-xl px-8">
                <p class="text-gray-800 text-lg mb-4">
                  <span class="font-semibold">{@selected_speaker.title}</span>
                  <span :if={@selected_speaker.company}> na </span>
                  <span :if={@selected_speaker.company} class="font-medium">
                    {@selected_speaker.company}
                  </span>
                </p>
                <p
                  :if={first_activity(@selected_speaker)}
                  class="text-gray-600 text-base leading-relaxed"
                >
                  Poderás ver o {String.split(@selected_speaker.name) |> List.first()} na tertúlia "{first_activity(
                    @selected_speaker
                  ).title}", dia {Calendar.strftime(first_activity(@selected_speaker).date, "%d")} às {Calendar.strftime(
                    first_activity(@selected_speaker).time_start,
                    "%Hh"
                  )}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp first_activity(speaker) do
    Enum.at(speaker.activities, 0)
  end
end
