defmodule PearlWeb.Landing.FAQLive.Components.Contacts do
  @moduledoc false
  use PearlWeb, :component

  @contacts [
    %{
      name: gettext("Telefone"),
      value: "+351 253 604 448",
      description:
        gettext(
          "És atendido da sede do CeSIUM, que organiza o ENEI. Recomendamos que ligues em dias úteis, das 11h às 19h."
        ),
      accent: "#25B82A",
      icon: "hero-phone-solid",
      link: "tel:+351253604448"
    },
    %{
      name: gettext("Instagram"),
      value: "@eneiconf",
      description:
        gettext(
          "És atendido através das DMs do Instagram. Prevemos responder-te em menos de 24h."
        ),
      accent: "#E65A9E",
      icon: "fa-brand-instagram",
      link: "https://www.instagram.com/eneiconf/"
    },
    %{
      name: gettext("Email"),
      value: "geral@eneiconf.pt",
      description:
        gettext("És atendido por correio eletrónico. Prevemos responder-te em menos de 24h."),
      accent: "#168DCD",
      icon: "hero-envelope-solid",
      link: "mailto:geral@eneiconf.pt"
    }
  ]

  def contacts(assigns) do
    assigns = Map.put(assigns, :contacts, @contacts)

    ~H"""
    <div class="px-3">
      <h2 class="text-2xl font-semibold">{gettext("Contacta-nos")}</h2>
      <p class="py-1">{gettext("Para qualquer problema, fala connosco.")}</p>
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-2.5 pt-6">
        <%= for contact <- @contacts do %>
          <.link
            href={contact.link}
            target="_blank"
            class="lg:bg-white rounded-4xl py-2 lg:py-6 lg:px-6 flex flex-col justify-between gap-3 group"
          >
            <div>
              <p class="font-medium">{contact.name}</p>
              <p class="pt-2">{contact.description}</p>
            </div>
            <div class="rounded-full lg:bg-[#EFEFED] bg-white flex flex-row items-center px-2 py-2 w-min">
              <div
                class="rounded-full w-12 h-12 flex items-center justify-center"
                style={"background-color: #{contact.accent};"}
              >
                <.icon
                  name={contact.icon}
                  class="w-6 h-6 m-1 text-white group-hover:-rotate-10 transition-transform"
                />
              </div>
              <p class="px-2 py-2 whitespace-nowrap">{contact.value}</p>
            </div>
          </.link>
        <% end %>
      </div>
    </div>
    """
  end
end
