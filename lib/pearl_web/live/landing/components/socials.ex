defmodule PearlWeb.Landing.Components.Socials do
  @moduledoc """
  Event socials component.
  """
  use PearlWeb, :component

  def socials(assigns) do
    ~H"""
    <ul class="flex items-center gap-2.5">
      <li :for={link <- links()}>
        <.link
          href={link.url}
          target="_blank"
          class="flex items-center justify-center w-[26px] h-[26px] rounded-[7px] bg-white/10 text-white/50 transition-all hover:bg-white/20 hover:text-white"
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
        icon: "fa-brand-x-twitter",
        url: "https://x.com/cesiuminho"
      },
      %{
        icon: "fa-brand-linkedin-in",
        url: "https://linkedin.com/company/eneiconf"
      },
      %{
        icon: "fa-brand-facebook",
        url: "https://facebook.com/eneiconf"
      }
    ]
  end
end
