defmodule PearlWeb.Landing.Components.Socials do
  @moduledoc """
  Event socials component.
  """
  use PearlWeb, :component

  def socials(assigns) do
    ~H"""
    <ul class="flex items-center gap-4 md:gap-5">
      <li :for={link <- links()} class="flex items-center justify-center">
        <.link
          href={link.url}
          target="_blank"
          class="transition-colors duration-75 ease-in hover:text-accent"
        >
          <.icon name={link.icon} class="w-4 h-4" />
        </.link>
      </li>
    </ul>
    """
  end

  defp links do
    [
      %{
        icon: "fa-brand-instagram",
        url: "https://instagram.com/eneiconf"
      },
      %{
        icon: "fa-brand-linkedin-in",
        url: "https://linkedin.com/company/eneiconf"
      },
      %{
        icon: "fa-brand-github",
        url: "https://github.com/cesium/pearl"
      },
      %{
        icon: "fa-brand-x-twitter",
        url: "https://x.com/cesiuminho"
      },
      %{
        icon: "fa-brand-facebook",
        url: "https://facebook.com/eneiconf"
      },
      %{
        icon: "hero-envelope-solid",
        url: "mailto:geral@eneiconf.pt"
      }
    ]
  end
end
