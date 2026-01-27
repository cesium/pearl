defmodule PearlWeb.Components.Modal do
  @moduledoc """
  Base modal component.
  """
  use PearlWeb, :component

  attr :rest, :global

  attr :id, :string, required: true
  attr :show, :boolean, default: false

  attr :backdrop_class, :string, default: "backdrop-blur-md transition-opacity bg-dark/50"

  attr :wrapper_class, :string, default: ""

  attr :body_class, :string,
    default: "bg-light dark:bg-dark p-8 sm:p-14 shadow-zinc-700/10 shadow-lg rounded-2xl"

  attr :on_cancel, JS, default: %JS{}

  attr :close_button, :boolean, default: true
  attr :close_button_class, :string, default: "absolute top-6 right-5"
  attr :close_button_icon_class, :string, default: "size-5"
  attr :close_button_button_class, :string,
    default: "-m-3 flex-none p-3 opacity-20 text-dark dark:text-light hover:opacity-40"

  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
      {@rest}
    >
      <div
        id={"#{@id}-bg"}
        class={[@backdrop_class, "fixed inset-0"]}
        aria-hidden="true"
      />

      <div
        class={"fixed inset-0 overflow-y-auto #{@wrapper_class}"}
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-4xl">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class={"relative hidden transition #{@body_class}"}
            >
              <div :if={@close_button} class={@close_button_class}>
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class={@close_button_button_class}
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class={@close_button_icon_class} />
                </button>
              </div>

              <div id={"#{@id}-content"}>
                {render_slot(@inner_block)}
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end
end
