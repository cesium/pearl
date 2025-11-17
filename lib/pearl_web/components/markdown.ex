defmodule PearlWeb.Components.Markdown do
  @moduledoc """
  Markdown component.
  """
  use PearlWeb, :component

  attr :content, :string, default: ""
  attr :class, :string, default: ""

  def markdown(assigns) do
    html =
      assigns.content
      |> String.trim()
      |> Earmark.as_html!()
      |> raw()

    assigns = assign(assigns, :html, html)

    ~H"""
    <section class={@class}>
      {@html}
    </section>
    """
  end
end
