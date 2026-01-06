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

  def action_button(assigns) do
    ~H"""
    <button
      disabled={@disabled}
      class={[
        "group flex items-center justify-between min-w-64 p-2",
        "rounded-full bg-background-muted transition-all",
        "hover:bg-background-muted/80",
        "disabled:opacity-50 disabled:cursor-not-allowed",
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
        class="flex items-center justify-center size-10 shrink-0 rounded-full bg-primary text-white transition-transform group-hover:scale-105 group-disabled:scale-100"
      >
        <.icon name={@icon} class="size-5" />
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
  attr :rest, :global, include: ~w(disabled phx-click phx-disable-with phx-target)

  def primary_button(assigns) do
    ~H"""
    <button
      class={[
        "flex items-center justify-center py-3",
        if(@small, do: "w-13 h-13", else: ["w-27 px-12 h-9", @gap]),
        "bg-primary text-white hover:bg-primary/80 disabled:opacity-50 disabled:cursor-not-allowed",
        @class
      ]}
      {@rest}
    >
      <%= if @small do %>
        <.icon name={@icon} class="w-5 h-5 shrink-0" />
      <% else %>
        <.icon name={@icon} class="w-4 h-4 shrink-0" />
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
        "flex items-center justify-center px-12 py-3",
        @gap,
        "bg-primary/10 text-primary hover:bg-primary/20 disabled:opacity-50 disabled:cursor-not-allowed",
        "w-22 h-9",
        @class
      ]}
      {@rest}
    >
      <%= if @icon_position == "left" do %>
        <.icon name={@icon} class="w-4 h-4 shrink-0" />
        <span class="text-base">{assigns.title}</span>
      <% else %>
        <span class="text-base">{assigns.title}</span>
        <.icon name={@icon} class="w-4 h-4 shrink-0" />
      <% end %>
    </button>
    """
  end
end
