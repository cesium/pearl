defmodule PearlWeb.Landing.Components.Navbar do
  @moduledoc false
  use PearlWeb, :component

  import PearlWeb.Components.{Avatar, Dropdown}
  import PearlWeb.Landing.Components.JoinUs

  attr :pages, :list, default: []
  attr :registrations_open?, :boolean, default: false
  attr :current_user, :map, default: nil

  def navbar(assigns) do
    ~H"""
    <div>
      <nav class="pt-8 pb-4 xl:px-[3rem] md:px-[2rem] px-[1rem]">
        <div class="flex h-16 items-center justify-between gap-8">
          <div class="flex-shrink-0">
            <.link href="/">
              <div class="block select-none h-full -translate-y-1">
                <img
                  src="/images/enei-logo.svg"
                  width={125}
                  alt="ENEI Logo"
                  class="cursor-pointer transition-colors duration-75 ease-in hover:text-accent h-full"
                />
              </div>
            </.link>
          </div>

          <div class="hidden xl:flex items-center flex-1">
            <div class="flex flex-row gap-6 2xl:gap-8">
              <%= for page <- @pages do %>
                <.link
                  navigate={page.url}
                  class="text-sm text-[#811824] transition-colors duration-75 ease-in hover:text-accent whitespace-nowrap"
                >
                  {page.title}
                </.link>
              <% end %>
            </div>
          </div>

          <div class="hidden xl:flex items-center flex-shrink-0">
            <.link
              :if={!@current_user}
              navigate={~p"/users/log_in"}
              class="flex items-center gap-2 h-10 px-5 border border-[#811824] bg-transparent text-[#811824] text-sm transition-all hover:bg-[#811824]/10"
            >
              <.icon name="hero-user" class="h-4 w-4" />
              <span>entrar</span>
            </.link>
            <div :if={@registrations_open? && !@current_user}>
              <.join_us />
            </div>
          </div>

          <div :if={@current_user} class="hidden xl:flex items-center flex-shrink-0">
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
            <span class="cursor-pointer text-[#811824]" phx-click={show_mobile_navbar()}>
              <.icon name="hero-bars-3" class="w-7 h-7" />
            </span>
          </div>
        </div>
      </nav>
      <div
        id="mobile-navbar"
        class="bg-[#EFEFED] w-full h-dvh overflow-y-auto absolute top-0 left-0 bottom-0 z-40 flex flex-col"
        style="display: none;"
      >
        <div class="w-full flex flex-col items-end px-10 py-12">
          <span class="cursor-pointer text-[#811824]" phx-click={hide_mobile_navbar()}>
            <.icon name="hero-x-mark" class="w-8 h-8" />
          </span>
        </div>
        <div class="flex flex-col w-full items-center gap-12 mb-16">
          <%= for page <- @pages do %>
            <.link
              navigate={page.url}
              phx-click={hide_mobile_navbar()}
              class="font-terminal uppercase text-2xl text-[#811824] transition-colors duration-75 ease-in hover:text-accent"
            >
              {page.title}
            </.link>
          <% end %>
          <.link
            :if={!@current_user}
            navigate={~p"/users/log_in"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-2xl text-[#811824] transition-colors duration-75 ease-in hover:text-accent"
          >
            Log in
          </.link>
          <.link
            :if={@registrations_open? && !@current_user}
            navigate={~p"/users/register"}
            phx-click={hide_mobile_navbar()}
            class="flex items-center gap-3 mt-6 px-8 py-3 rounded-lg border-2 border-[#811824] text-[#811824] text-lg font-medium transition-all hover:bg-[#811824] hover:text-white"
          >
            <.icon name="hero-arrow-right" class="h-5 w-5" />
            <span>inscrição</span>
          </.link>
          <.link
            :if={user_type?(@current_user, :staff)}
            patch={~p"/dashboard/scanner"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-2xl text-[#811824] transition-colors duration-75 ease-in hover:text-accent"
          >
            Dashboard
          </.link>
          <.link
            :if={user_type?(@current_user, :attendee)}
            patch={~p"/app"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-2xl text-[#811824] transition-colors duration-75 ease-in hover:text-accent"
          >
            App
          </.link>
          <.link
            :if={user_type?(@current_user, :company)}
            patch={~p"/sponsor/scanner"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-2xl text-[#811824] transition-colors duration-75 ease-in hover:text-accent"
          >
            Scanner
          </.link>
          <.link
            :if={@current_user}
            method="delete"
            href={~p"/users/log_out"}
            phx-click={hide_mobile_navbar()}
            class="font-terminal uppercase text-2xl text-[#811824] transition-colors duration-75 ease-in hover:text-accent"
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
