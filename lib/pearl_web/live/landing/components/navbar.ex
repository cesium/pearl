defmodule PearlWeb.Landing.Components.Navbar do
  @moduledoc false
  use PearlWeb, :component

  import PearlWeb.Components.{Avatar, Dropdown, Button}

  attr :pages, :list, default: []
  attr :registrations_open?, :boolean, default: false
  attr :current_user, :map, default: nil
  attr :dark_mode, :boolean, default: false
  attr :current_page, :atom, default: nil

  def navbar(assigns) do
    ~H"""
    <div class={[
      "sticky top-0 z-100 bg-linear-to-b to-transparent",
      if(@dark_mode,
        do: "from-dark via-dark/50 bg-dark/60",
        else: "from-white via-white/50 bg-light-muted/60"
      )
    ]}>
      <nav class="py-8.5 px-9 backdrop-blur-lg">
        <div class="flex h-fit items-center justify-between">
          <div class="flex gap-8">
            <div class="shrink-0">
              <.link href="/">
                <div class="block select-none h-full pb-1">
                  <img
                    src={
                      if @dark_mode, do: "/images/enei-logo-white.svg", else: "/images/enei-logo.svg"
                    }
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
                      "text-sm transition-colors duration-200 ease-in whitespace-nowrap",
                      if(@dark_mode,
                        do: "text-white hover:text-white/70",
                        else: "text-primary hover:text-primary/70"
                      ),
                      if(@current_page == page.key,
                        do:
                          "border-b-2 pt-2 pb-1.5 #{if(@dark_mode, do: "border-white/30", else: "border-primary/30")}"
                      )
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
              <.secondary_button
                title="entrar"
                icon_position="left"
                icon="hero-user"
                class={
                  if @dark_mode,
                    do: "text-sm text-white bg-white/20 hover:bg-white/10",
                    else: "text-sm"
                }
              />
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
                  name={@current_user.name}
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
              <.dropdown_menu_link_item
                :if={user_type?(@current_user, :staff)}
                link_type="a"
                to="/dashboard/scanner"
                label="Dashboard"
              />
              <.dropdown_menu_link_item
                :if={user_type?(@current_user, :attendee)}
                link_type="a"
                to={
                  if @current_user.confirmed_at,
                    do: "/app",
                    else: "/users/confirmation_pending"
                }
                label="App"
              />
              <.dropdown_menu_link_item
                :if={user_type?(@current_user, :attendee)}
                link_type="a"
                to={
                  if @current_user.confirmed_at,
                    do: "/settings",
                    else: "/users/confirmation_pending"
                }
                label="Settings"
              />
              <.dropdown_menu_link_item
                :if={user_type?(@current_user, :company)}
                link_type="a"
                to="/sponsor/scanner"
                label="Scanner"
              />
              <.dropdown_menu_link_item
                link_type="a"
                method="delete"
                to="/users/log_out"
                label="Sign Out"
              />
            </.dropdown>
          </div>

          <div class="block xl:hidden">
            <span
              class={"cursor-pointer #{if @dark_mode, do: "text-white", else: "text-primary"}"}
              phx-click={show_mobile_navbar()}
            >
              <.icon name="hero-bars-3" class="w-7 h-7" />
            </span>
          </div>
        </div>
      </nav>

      <div
        id="mobile-navbar"
        class="bg-background-muted/60 backdrop-blur-lg px-8 py-10 w-full h-dvh overflow-y-auto absolute top-0 left-0 bottom-0 z-40 flex flex-col gap-5"
        style="display: none;"
      >
        <div class="w-full flex items-end">
          <div
            class="grid grid-cols-[auto_1fr] gap-x-3.5 items-start"
            navigate={~p"/"}
            phx-click={hide_mobile_navbar()}
          >
            <img src="/images/enei-logo.svg" width={75} alt="ENEI Logo" class="row-span-2" />
            <p class="text-primary text-sm md:text-base mt-1 self-end">
              encontro nacional de estudantes de informática
            </p>
            <p class="text-primary/50 col-start-2">2026</p>
          </div>
        </div>

        <div class="flex flex-col w-full items-start gap-3 mb-16">
          <.link
            navigate="/"
            phx-click={hide_mobile_navbar()}
            class={[
              "text-2xl font-semibold transition-colors duration-75 ease-in hover:text-primary",
              if(@current_page == :home, do: "text-dark", else: "text-dark/50")
            ]}
          >
            Início
          </.link>
          <%= for page <- @pages do %>
            <.link
              navigate={page.url}
              phx-click={hide_mobile_navbar()}
              class={[
                "text-2xl font-semibold transition-colors duration-75 ease-in hover:text-primary",
                if(@current_page == page.key, do: "text-dark", else: "text-dark/50")
              ]}
            >
              {page.title}
            </.link>
          <% end %>

          <.link
            :if={user_type?(@current_user, :staff)}
            patch={~p"/dashboard/scanner"}
            phx-click={hide_mobile_navbar()}
            class="text-2xl font-semibold text-dark/50 transition-colors duration-75 ease-in hover:text-primary"
          >
            Dashboard
          </.link>
          <.link
            :if={user_type?(@current_user, :attendee)}
            patch={~p"/app"}
            phx-click={hide_mobile_navbar()}
            class="text-2xl font-semibold text-dark/50 transition-colors duration-75 ease-in hover:text-primary"
          >
            App
          </.link>
          <.link
            :if={user_type?(@current_user, :company)}
            patch={~p"/sponsor/scanner"}
            phx-click={hide_mobile_navbar()}
            class="text-2xl font-semibold text-dark/50 transition-colors duration-75 ease-in hover:text-primary"
          >
            Scanner
          </.link>
        </div>

        <div class="flex flex-col items-center gap-10 justify-center w-full mt-auto">
          <div class="flex items-center justify-center w-full ">
            <%= if !@current_user do %>
              <.link
                navigate={~p"/users/log_in"}
                phx-click={hide_mobile_navbar()}
                class="text-xl flex items-center gap-2 px-4 font-semibold text-dark/50 transition-colors duration-75 ease-in hover:text-primary"
              >
                <.icon name="fa-user" class="w-5 h-5" />
                <span>Entrar</span>
              </.link>
            <% else %>
              <.link
                method="delete"
                href={~p"/users/log_out"}
                phx-click={hide_mobile_navbar()}
                class="text-xl flex items-center gap-2 px-4 font-semibold text-dark/50 transition-colors duration-75 ease-in hover:text-primary"
              >
                <.icon name="hero-arrow-left-end-on-rectangle" class="w-5 h-5" />
                <span>Sair</span>
              </.link>
            <% end %>

            <.link
              :if={@registrations_open? && !@current_user}
              navigate={~p"/users/register"}
              phx-click={hide_mobile_navbar()}
              class="flex items-center gap-3 px-4 py-2 rounded-lg border-2 border-primary text-primary text-lg font-medium transition-all hover:bg-primary hover:text-white"
            >
              <.icon name="hero-arrow-right" class="h-5 w-5" />
              <span>inscrição</span>
            </.link>
          </div>

          <span
            class="cursor-pointer rounded-full flex items-center justify-center w-12.5 h-12.5 bg-primary "
            phx-click={hide_mobile_navbar()}
          >
            <.icon name="hero-x-mark" class="w-8 h-8 text-white" />
          </span>
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
        {"transition ease-in-out duration-300 transform", "-translate-y-full", "translate-y-0"}
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
        {"transition ease-in-out duration-300 transform", "translate-y-0", "-translate-y-full"}
    )
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.show(to: "#show-mobile-navbar", transition: "fade-in")
    |> JS.dispatch("js:call", to: "#show-mobile-navbar", detail: %{call: "focus", args: []})
  end

  defp user_type?(user, type) do
    user && user.type == type
  end
end
