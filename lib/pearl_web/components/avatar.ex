defmodule PearlWeb.Components.Avatar do
  @moduledoc false
  use PearlWeb, :component

  @palette_colors [
    "#ED498D",
    "#24B0E7",
    "#DFB13E",
    "#96D628",
    "#7575D7",
    "#811824"
  ]

  attr :src, :string, default: nil, doc: "The URL of the image to display."

  attr :size, :atom,
    values: [:xs, :sm, :md, :lg, :xl],
    default: :md,
    doc: "The size of the avatars."

  attr :type, :atom,
    values: [:user, :company],
    default: :user,
    doc: "The type of entity associated with the avatar."

  attr :class, :string, default: nil, doc: "Additional classes to be added to the avatar."

  attr :name, :string, doc: "The name of the user."

  attr :link, :string, default: nil, doc: "The URL to link to when the avatar is clicked."

  def avatar(%{link: nil} = assigns) do
    ~H"""
    {inner_avatar(assigns)}
    """
  end

  def avatar(assigns) do
    ~H"""
    <.link navigate={@link}>
      {inner_avatar(assigns)}
    </.link>
    """
  end

  defp inner_avatar(assigns) do
    ~H"""
    <span class={generate_avatar_classes(assigns)}>
      <%= if @src do %>
        <img src={@src} class="h-full w-full rounded-full" />
      <% else %>
        <div
          class="flex items-center justify-center text-white w-full h-full rounded-full"
          style={"background-color: #{generate_avatar_color(@name)}"}
        >
          <span>{get_handle_initials(@name)}</span>
        </div>
      <% end %>
    </span>
    """
  end

  defp generate_avatar_classes(assigns) do
    [
      "pearl-avatar",
      "pearl-avatar--#{assigns.size}",
      "pearl-avatar--#{assigns.type}",
      assigns.class
    ]
  end

  defp generate_avatar_color(name) do
    pos =
      name
      |> String.downcase()
      |> String.to_charlist()
      |> Enum.reduce(0, fn char, acc ->
        acc + char
      end)
      |> rem(length(@palette_colors))

    Enum.at(@palette_colors, pos)
  end

  defp get_handle_initials(name) do
    parts = name |> String.split(" ", trim: true)

    initials =
      case parts do
        [single] ->
          String.first(single)

        [first | rest] ->
          last = List.last(rest)
          String.first(first) <> String.first(last)

        _ ->
          ""
      end

    String.upcase(initials)
  end
end
