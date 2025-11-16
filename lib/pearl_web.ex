defmodule PearlWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use PearlWeb, :controller
      use PearlWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets docs fonts images models favicon.ico robots.txt 30anos.html)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: PearlWeb.Layouts]

      import Plug.Conn
      use Gettext, backend: PearlWeb.Gettext

      unquote(verified_routes())
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/pearl_web/templates",
        namespace: PearlWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(html_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {PearlWeb.Layouts, :default}

      unquote(html_helpers())
    end
  end

  def app_view do
    quote do
      use Phoenix.LiveView,
        layout: {PearlWeb.Layouts, :app}

      import PearlWeb.Components.Avatar
      import PearlWeb.Components.Button

      unquote(html_helpers())
    end
  end

  def sponsor_view do
    quote do
      use Phoenix.LiveView,
        layout: {PearlWeb.Layouts, :sponsor}

      import PearlWeb.Components.Button

      unquote(html_helpers())
    end
  end

  def backoffice_view do
    quote do
      use Phoenix.LiveView,
        layout: {PearlWeb.Layouts, :backoffice}

      import PearlWeb.Components.Avatar
      import PearlWeb.Components.EnsurePermissions
      import PearlWeb.BackofficeHelpers

      unquote(html_helpers())
    end
  end

  def landing_view do
    quote do
      use Phoenix.LiveView,
        layout: {PearlWeb.Layouts, :landing}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      import PearlWeb.Components.Avatar
      unquote(html_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import PearlWeb.CoreComponents
      import PearlWeb.Components.Page
      use Gettext, backend: PearlWeb.Gettext

      import PearlWeb.Helpers

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())

      alias Pearl.Uploaders
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: PearlWeb.Endpoint,
        router: PearlWeb.Router,
        statics: PearlWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
