defmodule PearlWeb.Components.Markdown do
  @moduledoc """
  Markdown component.
  """
  use PearlWeb, :component

  attr :content, :string, default: ""
  attr :class, :string, default: ""

  def markdown(assigns) do
    content = assigns.content || ""

    html =
      content
      |> String.trim()
      |> Earmark.as_html!()
      |> raw()

    assigns = assign(assigns, :html, html)

    ~H"""
    <section class="markdown-body #{@class}">
      {@html}
    </section>
    """
  end
end
