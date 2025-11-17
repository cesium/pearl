defmodule PearlWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use PearlWeb, :controller` and
  `use PearlWeb, :live_view`.
  """
  use PearlWeb, :html

  import PearlWeb.Components.Sidebar
  import PearlWeb.Landing.Components.{Footer, Navbar, Sparkles}
  import PearlWeb.Components.Banner

  embed_templates "layouts/*"
end
