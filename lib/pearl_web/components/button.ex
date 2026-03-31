defmodule PearlWeb.Components.Button do
  @moduledoc """
  Button component.
  """
  use PearlWeb, :component

  import PearlWeb.CoreComponents

  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :icon, :string, default: "hero-arrow-right"
  attr :disabled, :boolean, default: false
  attr :class, :string, default: ""
  attr :title_class, :string, default: ""

  attr :rest, :global,
    include:
      ~w(csrf_token download form href hreflang method name navigate patch referrerpolicy rel replace target type value autofocus tabindex),
    doc: "Arbitrary HTML or phx attributes."

  def navigate_button(assigns) do
    ~H"""
    <.link
      class={[
        "flex group items-center justify-between min-w-64 p-2",
        "rounded-full bg-background-muted transition-all",
        "hover:bg-background-muted/80",
        @disabled && "opacity-50 cursor-not-allowed pointer-events-none",
        @class
      ]}
      {@rest}
    >
      <div class="flex flex-col items-center mx-auto px-4">
        <span class={[
          "text-dark text-md lowercase tracking-tight leading-tight",
          @title_class
        ]}>
          {@title}
        </span>

        <%= if @subtitle do %>
          <span class="text-xs opacity-70 font-terminal lowercase">
            {@subtitle}
          </span>
        <% end %>
      </div>

      <div
        :if={@icon != ""}
        class="flex items-center justify-center size-10 shrink-0 rounded-full bg-primary text-white transition-transform group-hover:scale-105"
      >
        <.icon name={@icon} class="size-5 transition-transform group-hover:scale-105" />
      </div>
    </.link>
    """
  end

  attr :title, :string, default: ""
  attr :subtitle, :string, default: ""
  attr :subtitle_icon, :string, default: ""
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
      class={"m-auto block select-none cursor-pointer uppercase transition-all duration-300 ease-in-out text-2xl font-semibold disabled:hover:border-white disabled:hover:text-white disabled:cursor-not-allowed disabled:bg-light/20 disabled:opacity-75 h-20 w-full border-2 border-light/80 text-white hover:shadow-[0_0_20px_1px] shadow-primary/50 hover:border-transparent hover:bg-primary/70 rounded-2xl #{@class}"}
      disabled={@disabled}
      {@rest}
    >
      <%= if @icon != "" do %>
        <.icon name={@icon} />
      <% end %>
      <p class={"uppercase text-2xl font-semibold #{@title_class}"}>{@title}</p>
      <div
        :if={@subtitle != "" || @subtitle_icon != ""}
        class={["inline-flex items-center justify-center", @subtitle_icon != "" && "gap-2"]}
      >
        <%= if @subtitle_icon do %>
          <.icon name={"fa-" <> @subtitle_icon} class="size-3" />
        <% end %>
        <p class="text-base font-light/50">{@subtitle}</p>
      </div>
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
  attr :rest, :global, include: ~w(disabled phx-click phx-disable-with phx-target form)

  def primary_button(assigns) do
    ~H"""
    <button
      class={[
        "flex items-center justify-center",
        if(@small, do: "w-13 h-13", else: ["px-4 py-2.5", @gap]),
        "bg-primary text-white hover:bg-primary/80 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer",
        @class
      ]}
      {@rest}
    >
      <%= if @small do %>
        <.icon name={@icon} class="w-5 h-5 shrink-0" />
      <% else %>
        <.icon name={@icon} class="w-4 h-4 shrink-0" />
        <span>{assigns.title}</span>
      <% end %>
    </button>
    """
  end

  @doc """
  Renders a secondary button with icon and title.

  ## Examples

      <.secondary_button title="Continue" />
      <.secondary_button title="Next" icon_position="left" />
      <.secondary_button title="Help" no_icon />
  """
  attr :title, :string, required: true
  attr :icon, :string, default: "hero-arrow-left"
  attr :icon_position, :string, default: "right", values: ["left", "right"]
  attr :no_icon, :boolean, default: false
  attr :gap, :string, default: "gap-1.5"
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled phx-click phx-disable-with phx-target)

  def secondary_button(assigns) do
    ~H"""
    <button
      class={[
        "flex items-center justify-center py-2.5 px-4",
        if(@no_icon, do: "", else: @gap),
        "bg-primary/10 text-primary hover:bg-primary/20 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer",
        @class
      ]}
      {@rest}
    >
      <%= if @no_icon do %>
        <span>{assigns.title}</span>
      <% else %>
        <%= if @icon_position == "left" do %>
          <.icon name={@icon} class="w-4 h-4 shrink-0" />
          <span>{assigns.title}</span>
        <% else %>
          <span>{assigns.title}</span>
          <.icon name={@icon} class="w-4 h-4 shrink-0" />
        <% end %>
      <% end %>
    </button>
    """
  end
end
