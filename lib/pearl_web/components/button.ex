defmodule PearlWeb.Components.Button do
  @moduledoc """
  Button component.
  """
  use PearlWeb, :component

  import PearlWeb.CoreComponents

  attr :title, :string, default: ""
  attr :subtitle, :string, default: ""
  attr :disabled, :boolean, default: false
  attr :icon, :string, default: ""
  attr :class, :string, default: ""
  attr :title_class, :string, default: ""

  attr :rest, :global,
    include:
      ~w(csrf_token download form href hreflang method name navigate patch referrerpolicy rel replace target type value autofocus tabindex),
    doc: "Arbitrary HTML or phx attributes."

  def action_button(assigns) do
    ~H"""
    <button
      class={"m-auto block select-none rounded-full hover:opacity-75 disabled:hover:border-white disabled:hover:text-white disabled:cursor-not-allowed disabled:bg-gray-400 disabled:opacity-75 h-20 w-full border-2 border-white text-white transition-colors hover:border-accent hover:bg-accent/10 hover:text-accent #{@class}"}
      disabled={@disabled}
      {@rest}
    >
      <%= if @icon != "" do %>
        <.icon name={@icon} />
      <% end %>
      <p class={"uppercase font-terminal text-2xl #{@title_class}"}>{@title}</p>
      <p class="font-terminal">{@subtitle}</p>
    </button>
    """
  end

  @doc """
  Renders a backoffice_button.

  ## Examples

      <.backoffice_button>Send!</.backoffice_button>
      <.backoffice_button phx-click="go" class="ml-2">Send!</.backoffice_button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def backoffice_button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-dark text-light dark:bg-light dark:text-dark hover:bg-darkShade dark:hover:bg-lightShade/95 py-2 px-3",
        "text-sm font-semibold leading-6 transition-colors",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Renders a primary button with icon and title.

  ## Examples

      <.primary_button title="Continue" />
      <.primary_button title="Next" class="w-full" />
      <.primary_button small />
  """
  attr :title, :string, default: nil
  attr :icon, :string, default: "hero-arrow-right"
  attr :small, :boolean, default: false
  attr :gap, :string, default: "gap-1.5"
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled phx-click phx-disable-with phx-target)

  def primary_button(assigns) do
    ~H"""
    <button
      class={[
        "flex items-center justify-center px-6 py-3",
        if(@small, do: "w-[50px] h-[50px]", else: ["w-[139px] h-[43px]", @gap]),
        "bg-[#811824] text-white hover:bg-[#6b1420] disabled:opacity-50 disabled:cursor-not-allowed",
        "font-normal transition-colors font-['Space_Grotesk']",
        @class
      ]}
      {@rest}
    >
      <%= if @small do %>
        <.icon name={@icon} class="w-6 h-6 shrink-0" />
      <% else %>
        <.icon name={@icon} class="w-6 h-6 shrink-0" />
        <span class="text-base">{assigns.title}</span>
      <% end %>
    </button>
    """
  end

  @doc """
  Renders a secondary button with icon and title.

  ## Examples

      <.secondary_button title="Continue" />
      <.secondary_button title="Next" icon_position="left" />
  """
  attr :title, :string, required: true
  attr :icon, :string, default: "hero-arrow-left"
  attr :icon_position, :string, default: "right", values: ["left", "right"]
  attr :gap, :string, default: "gap-1.5"
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled phx-click phx-disable-with phx-target)

  def secondary_button(assigns) do
    ~H"""
    <button
      class={[
        "flex items-center justify-center px-6 py-3",
        @gap,
        "bg-[#81182410] text-[#811824] hover:bg-[#81182420] disabled:opacity-50 disabled:cursor-not-allowed",
        "font-normal transition-colors font-['Space_Grotesk']",
        "w-[125px] h-[43px]",
        @class
      ]}
      {@rest}
    >
      <%= if @icon_position == "left" do %>
        <.icon name={@icon} class="w-6 h-6 shrink-0" />
        <span class="text-base">{assigns.title}</span>
      <% else %>
        <span class="text-base">{assigns.title}</span>
        <.icon name={@icon} class="w-6 h-6 shrink-0" />
      <% end %>
    </button>
    """
  end
end
