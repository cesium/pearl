defmodule PearlWeb.UserRegistrationLiveTest do
  use PearlWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Pearl.AccountsFixtures

  alias Pearl.Constants

  setup do
    Constants.set("registrations_open", "true")
    :ok
  end

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Inscrição"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/register")
        |> follow_redirect(conn, "/app/")

      assert {:ok, _conn} = result
    end

    test "Registration page renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      lv
      |> form("#registration_form", user: %{})
      |> render_submit()

      result =
        lv
        |> element("#registration_form")
        |> render_change(user: %{"email" => "with spaces"})

      assert result =~ "Inscrição"
      assert result =~ "must have the @ sign and no spaces"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element("a[href='/users/log_in'].text-sm")
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert login_html =~ "Log in"
    end
  end
end
