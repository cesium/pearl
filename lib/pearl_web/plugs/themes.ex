defmodule PearlWeb.Themes do
  @moduledoc false
  use PearlWeb, :verified_routes

  import Plug.Conn

  def put_theme_color(conn, _opts) do
    color =
      if String.starts_with?(conn.request_path, "/app"),
        do: "#0a0a0a",
        else: "#ffffff"

    assign(conn, :theme_color, color)
  end
end
