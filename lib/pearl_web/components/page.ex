defmodule PearlWeb.Components.Page do
  @moduledoc """
  Page layout component.
  """
  use Phoenix.Component

  import PearlWeb.CoreComponents

  attr :title, :string, default: ""
  attr :subtitle, :string, default: ""
  attr :style, :atom, values: [:app, :backoffice], default: :app
  attr :size, :atom, values: [:sm, :md, :xl], default: :md
  attr :title_class, :string, default: ""
  attr :subtitle_class, :string, default: ""
  attr :back_to_link_class, :string, default: ""
  attr :back_to_link, :string, default: nil
  attr :back_to_link_text, :string, default: "Back"
  attr :banner, :string, default: nil
  attr :child_class, :string, default: nil
  attr :stack_header_on_mobile, :boolean, default: false

  slot :actions, required: false, doc: "Slot for actions to be rendered in the page header."
  slot :inner_block, required: true, doc: "Slot for the body content of the page."

  def page(assigns) do
    ~H"""
    <div>
      <.header
        title_class={"#{size_class(@size)} #{@title_class}"}
        actions_layout={if @stack_header_on_mobile, do: :stack_mobile, else: :inline}
        class={header_class(@banner, @stack_header_on_mobile)}
        style={header_style(@banner)}
        overlay_class={
          @banner && "bg-gradient-to-t from-app-dark-soft from-0% to-transparent to-[60%]"
        }
      >
        {@title}
        <:subtitle :if={@subtitle != "" || @back_to_link}>
          <div class="flex flex-col gap-2">
            <span :if={@subtitle != ""} class={@subtitle_class}>{@subtitle}</span>
            <.link
              :if={@back_to_link}
              patch={@back_to_link}
              class={["inline-flex items-center gap-1 group", @back_to_link_class]}
            >
              <.icon
                name="fa-arrow-left-solid"
                class="size-4 group-hover:-translate-x-0.5 transition-transform duration-300"
              />
              {@back_to_link_text}
            </.link>
          </div>
        </:subtitle>
        <:actions>
          {render_slot(@actions)}
        </:actions>
      </.header>
      <div class={[
        @child_class,
        content_padding_class(@stack_header_on_mobile)
      ]}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  def size_class(size) do
    %{
      sm: "text-md",
      md: "text-lg",
      xl: "text-3xl"
    }[size]
  end

  defp header_style(nil), do: nil

  defp header_style(banner),
    do: "background-image: url(#{banner}); background-position: center; background-size: cover;"

  defp header_class(nil, stack_header_on_mobile), do: header_padding_class(stack_header_on_mobile)

  defp header_class(_banner, stack_header_on_mobile),
    do:
      "min-h-40 text-white items-end! pt-0 pb-5.5 " <>
        header_padding_class(stack_header_on_mobile)

  defp header_padding_class(true), do: "py-2"

  defp header_padding_class(false), do: "px-6 lg:px-8 py-9"

  defp content_padding_class(true), do: "pb-28 lg:pb-8"

  defp content_padding_class(false), do: "px-6 sm:px-6 lg:px-8 pb-28 lg:pb-8"
end
