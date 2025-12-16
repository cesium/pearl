defmodule PearlWeb.Landing.HomeLive.Components.Activities do
  @moduledoc false
  use PearlWeb, :component

  def activities(assigns) do
    activities = [
      %{
        "img_path" => "/images/activities/stands.png",
        "icon_name" => "hero-briefcase",
        "title" => "Stands",
        "description" =>
          "As empresas terão balcões pelo recinto para poderes conhecer as oportunidades que têm para ti."
      },
      %{
        "img_path" => "/images/activities/talks.png",
        "icon_name" => "hero-presentation-chart-line",
        "title" => "Talks",
        "description" =>
          "As empresas terão balcões pelo recinto para poderes conhecer as oportunidades que têm para ti."
      },
      %{
        "img_path" => "/images/activities/workshops.png",
        "icon_name" => "hero-wrench-screwdriver",
        "title" => "Workshops",
        "description" =>
          "As empresas terão balcões pelo recinto para poderes conhecer as oportunidades que têm para ti."
      },
      %{
        "img_path" => "/images/activities/panel-discussions.png",
        "icon_name" => "hero-user-group",
        "title" => "Panel Discussions",
        "description" =>
          "Tertúlios com múltiplos convidados que discutem um assunto entre si, criando um momento de aprendizagem."
      },
      %{
        "img_path" => "/images/activities/pitch.png",
        "icon_name" => "hero-megaphone",
        "title" => "Pitch",
        "description" =>
          "Durante 15 minutos, vais ouvir sobre a experiência de trabalho numa empresa - aí, podes deixar o teu contacto."
      },
      %{
        "img_path" => "/images/activities/gameshows.png",
        "icon_name" => "hero-puzzle-piece",
        "title" => "Gameshows",
        "description" =>
          "Concursos ao vivo nos quais podes ser tanto espectador como participante - e, possivelmente, premiado!"
      },
      %{
        "img_path" => "/images/activities/eventos-sociais.png",
        "icon_name" => "hero-chat-bubble-left-right",
        "title" => "Eventos sociais",
        "description" =>
          "Focados em ligar-te a toda a gente do evento; tanto colegas como profissionais."
      }
    ]

    assigns = assign(assigns, :activities, activities)

    ~H"""
    <div class="px-[52px] pb-[70px] pt-[60px] w-full flex flex-col items-center gap-10 bg-white">
      <span class="flex flex-col gap-3.5 items-center text-dark-text max-w-[755px] text-center">
        <h1 class="text-[32px] font-semibold">{"Há sempre algo para fazer"}</h1>
        <p>
          {"O calendário é preenchido ao longo dos quatro dias do ENEI - conhece o tipo de atividades que estarão disponíveis."}
        </p>
      </span>
      <div class="grid grid-cols-4 gap-1 overflow-hidden border-light-muted border-2">
        <%= for activity <- @activities do %>
          <.activity_card
            img_path={activity["img_path"]}
            icon_name={activity["icon_name"]}
            title={activity["title"]}
            description={activity["description"]}
          />
        <% end %>
        <div class="relative size-full flex flex-col p-4 gap-6 text-dark-text after:absolute before:absolute after:bg-light-muted before:bg-light-muted after:[inline-size:100vw] before:[inline-size:2px] after:[block-size:2px] before:[block-size:100vh] after:start-0 before:-start-0.5 after:[inset-block-start:-2px] before:[inset-block-start:0]">
          <img
            src="/images/activities/decoration.svg"
            class="absolute left-0 top-0 right-0 bottom-0 size-full object-cover z-10"
          />
          <div class="flex flex-col justify-end h-full z-20 pb-3 px-3">
            <p class="font-grotesk text-sm text-black/50">
              {"Imagens da SEI ‘25 - Semena da Engenharia Informática 2025 em Braga, organizada também pelo CeSIUM."}
              <a href="#" class="text-primary underline">
                {"Sabe mais sobre o papel do CeSIUM no ENEI"}
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp activity_card(assigns) do
    ~H"""
    <div class="relative size-full flex flex-col p-4 gap-6 text-dark-text after:absolute before:absolute after:bg-light-muted before:bg-light-muted after:[inline-size:100vw] before:[inline-size:2px] after:[block-size:2px] before:[block-size:100vh] after:start-0 before:-start-0.5 after:[inset-block-start:-2px] before:[inset-block-start:0]">
      <img
        src={@img_path}
        alt={@title}
        class="w-full h-20 object-cover rounded-lg"
      />
      <div class="flex flex-col gap-2.5 font-grotesk pb-8">
        <.icon name={@icon_name} class="size-8" />
        <p class="font-bold">{@title}</p>
        <p>{@description}</p>
      </div>
    </div>
    """
  end
end
