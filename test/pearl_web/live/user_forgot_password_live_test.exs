defmodule PearlWeb.UserForgotPasswordLiveTest do
  use PearlWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Pearl.AccountsFixtures

  alias Pearl.Accounts
  alias Pearl.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/reset_password")

      assert html =~ "Recuperar palavra-passe"
      assert html =~ "Enviaremos um link de recuperação para o teu email"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/reset_password")
        |> follow_redirect(conn, ~p"/app/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{user: user_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", user: %{"email" => user.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Enum.any?([:info, :success, :error, :tip, :help], fn key ->
               value = Phoenix.Flash.get(conn.assigns.flash, key)
               is_binary(value) and value =~ "Se o teu email estiver no nosso sistema"
             end)

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", user: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      keys = [:info, :success, :error, :tip, :help, "info", "success", "error", "tip", "help"]

      assert Enum.any?(keys, fn key ->
               value = Phoenix.Flash.get(conn.assigns.flash, key)
               is_binary(value) and String.contains?(value, "teu email estiver no nosso sistema")
             end)

      assert Repo.all(Accounts.UserToken) == []
    end
  end
end
