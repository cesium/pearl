defmodule PearlWeb.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.

  See config/config.exs.
  """
  use PearlWeb, :html

  import PearlWeb.Landing.Components.{Footer, Navbar, Sparkles}

  embed_templates "error_html/*"
end
