defmodule PearlWeb.Landing.ChallengesLive.Components.Medal do
  @moduledoc """
  Medal component with customizable colors and text
  """
  use Phoenix.Component

  attr :text, :string, required: true
  attr :color, :string, default: "#B29C88"
  attr :class, :string, default: ""

  def medal(assigns) do
    ~H"""
    <svg
      width="30"
      height="42"
      viewBox="0 0 30 42"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      class={["shrink-0", @class]}
    >
      <path d="M8 28H22V42L15 35L8 42V28Z" fill={@color} />
      <path
        d="M8 28H22V42L15 35L8 42V28Z"
        fill="url(#paint0_linear_2046_8628)"
        fill-opacity="0.2"
      />
      <rect width="30" height="30" rx="15" fill={@color} />
      <rect x="2" y="2" width="26" height="26" rx="13" fill={@color} />
      <rect
        x="3"
        y="3"
        width="24"
        height="24"
        rx="12"
        stroke="black"
        stroke-opacity="0.1"
        stroke-width="2"
      />
      <text
        x="15"
        y="20"
        text-anchor="middle"
        fill="#EFEFED"
        font-size="14"
        font-weight="600"
        font-family="system-ui, -apple-system, sans-serif"
      >
        {@text}
      </text>
      <defs>
        <linearGradient
          id="paint0_linear_2046_8628"
          x1="15"
          y1="26"
          x2="15"
          y2="42"
          gradientUnits="userSpaceOnUse"
        >
          <stop />
          <stop offset="1" stop-opacity="0" />
        </linearGradient>
      </defs>
    </svg>
    """
  end
end
