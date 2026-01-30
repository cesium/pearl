defmodule PearlWeb.Landing.Components.Navbar do
  @moduledoc false
  use PearlWeb, :component

  import PearlWeb.Components.{Avatar, Dropdown, Button}

  attr :pages, :list, default: []
  attr :registrations_open?, :boolean, default: false
  attr :current_user, :map, default: nil
  attr :current_page, :atom, default: nil

  def navbar(assigns) do
    ~H"""
    <div>
      <nav class="py-8.5 px-9">
        <div class="flex h-fit items-center justify-between">
          <div class="flex gap-8">
            <div class="shrink-0">
              <.link href="/">
                <div class="block select-none h-full pb-1">
                  <img
                    src="/images/enei-logo.svg"
                    width={75}
                    alt="ENEI Logo"
                    class="cursor-pointer h-full"
                  />
                </div>
              </.link>
            </div>

            <div class="hidden xl:flex items-center flex-1 self-end">
              <div class="flex flex-row items-center h-8.5 mt-2 gap-5">
                <%= for page <- @pages do %>
                  <.link
                    navigate={page.url}
                    class={[
                      "text-sm text-primary transition-colors duration-200 ease-in hover:text-primary/70 whitespace-nowrap",
                      if(@current_page == page.key, do: "border-b-2 border-primary/30 pt-2 pb-1.5")
                    ]}
                  >
                    {page.title}
                  </.link>
                <% end %>
              </div>
            </div>
          </div>

          <div class="hidden xl:flex items-center shrink-0">
            <.link
              :if={!@current_user}
              navigate={~p"/users/log_in"}
              phx-click={hide_mobile_navbar()}
            >
              <.secondary_button title="entrar" icon_position="left" icon="hero-user" class="text-sm" />
            </.link>
            <.link
              :if={@registrations_open? && !@current_user}
              navigate={~p"/users/register"}
              phx-click={hide_mobile_navbar()}
            >
              <.primary_button title="inscrição" class="text-sm" />
            </.link>
          </div>

          <div :if={@current_user} class="hidden xl:flex items-center shrink-0">
            <.dropdown>
              <:trigger_element>
                <.avatar
                  handle={@current_user.handle}
                  src={
                    Uploaders.UserPicture.url(
                      {@current_user.picture, @current_user},
                      :original,
                      signed: true
                    )
                  }
                  size={:sm}
                  class="ring-2 rounded-full ring-white"
                />
              </:trigger_element>
              <.dropdown_menu_item
                :if={user_type?(@current_user, :staff)}
                link_type="a"
                to="/dashboard/scanner"
                label="Dashboard"
              />
              <.dropdown_menu_item
                :if={user_type?(@current_user, :attendee)}
                link_type="a"
                to={
                  if @current_user.confirmed_at,
                    do: "/app",
                    else: "/users/confirmation_pending"
                }
                label="App"
              />
              <.dropdown_menu_item
                :if={user_type?(@current_user, :company)}
                link_type="a"
                to="/sponsor/scanner"
                label="Scanner"
              />
              <.dropdown_menu_item
                link_type="a"
                method="delete"
                to="/users/log_out"
                label="Sign Out"
              />
            </.dropdown>
          </div>

          <div class="block xl:hidden">
            <span class="cursor-pointer text-primary" phx-click={show_mobile_navbar()}>
              <.icon name="hero-bars-3" class="w-7 h-7" />
            </span>
          </div>
        </div>
      </nav>
      <div
        id="mobile-navbar"
        class="bg-background-muted w-full h-dvh overflow-y-auto absolute top-0 left-0 bottom-0 z-40 flex flex-col"
        style="display: none;"
      >
        <div class="w-full flex flex-col items-end px-10 py-12">
          <span class="cursor-pointer text-primary" phx-click={hide_mobile_navbar()}>
            <.icon name="hero-x-mark" class="w-8 h-8" />
          </span>
        </div>
        <div class="flex flex-col w-full items-center gap-12 mb-16">
          <%= for page <- @pages do %>
            <.link
              navigate={page.url}
              phx-click={hide_mobile_navbar()}
              class="font-terminal uppercase text-2xl text-primary transition-colors duration-75 ease-in hover:text-accent"
            >
              {page.title}
            </.link>
          <% end %>
          <.link
            :if={!@current_user}
            navigate={~p"/users/log_in"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-2xl text-primary transition-colors duration-75 ease-in hover:text-accent"
          >
            Log in
          </.link>
          <.link
            :if={@registrations_open? && !@current_user}
            navigate={~p"/users/register"}
            phx-click={hide_mobile_navbar()}
            class="flex items-center gap-3 mt-6 px-8 py-3 rounded-lg border-2 border-primary text-primary text-lg font-medium transition-all hover:bg-primary hover:text-white"
          >
            <.icon name="hero-arrow-right" class="h-5 w-5" />
            <span>inscrição</span>
          </.link>
          <.link
            :if={user_type?(@current_user, :staff)}
            patch={~p"/dashboard/scanner"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-2xl text-primary transition-colors duration-75 ease-in hover:text-accent"
          >
            Dashboard
          </.link>
          <.link
            :if={user_type?(@current_user, :attendee)}
            patch={~p"/app"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-2xl text-primary transition-colors duration-75 ease-in hover:text-accent"
          >
            App
          </.link>
          <.link
            :if={user_type?(@current_user, :company)}
            patch={~p"/sponsor/scanner"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-2xl text-primary transition-colors duration-75 ease-in hover:text-accent"
          >
            Scanner
          </.link>
          <.link
            :if={@current_user}
            method="delete"
            href={~p"/users/log_out"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-2xl text-primary transition-colors duration-75 ease-in hover:text-accent"
          >
            Sign Out
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def show_mobile_navbar(js \\ %JS{}) do
    js
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.show(to: "#mobile-navbar-container", transition: "fade-in")
    |> JS.show(
      to: "#mobile-navbar",
      display: "flex",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "-translate-x-full", "translate-x-0"}
    )
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.hide(to: "#show-mobile-navbar", transition: "fade-out")
    |> JS.dispatch("js:call", to: "#hide-mobile-navbar", detail: %{call: "focus", args: []})
  end

  def hide_mobile_navbar(js \\ %JS{}) do
    js
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.hide(to: "#mobile-navbar-container", transition: "fade-out")
    |> JS.hide(
      to: "#mobile-navbar",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "translate-x-0", "-translate-x-full"}
    )
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.show(to: "#show-mobile-navbar", transition: "fade-in")
    |> JS.dispatch("js:call", to: "#show-mobile-navbar", detail: %{call: "focus", args: []})
  end

  defp user_type?(user, type) do
    user && user.type == type
  end
end
