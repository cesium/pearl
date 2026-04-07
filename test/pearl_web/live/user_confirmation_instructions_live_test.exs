defmodule PearlWeb.UserConfirmationInstructionsLiveTest do
  use PearlWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Pearl.AccountsFixtures

  alias Pearl.Accounts
  alias Pearl.Repo

  setup do
    %{user: user_fixture()}
  end

  describe "Resend confirmation" do
    test "renders the resend confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/confirm")
      assert html =~ "Resend confirmation instructions"
    end

    test "sends a new confirmation token", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      keys = [:info, :success, :error, :tip, :help, "info", "success", "error", "tip", "help"]

      assert Enum.any?(keys, fn key ->
               value = Phoenix.Flash.get(conn.assigns.flash, key)
               is_binary(value) and String.contains?(value, "teu email estiver no nosso sistema")
             end)

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "confirm"
    end

    test "does not send confirmation token if user is confirmed", %{conn: conn, user: user} do
      Repo.update!(Accounts.User.confirm_changeset(user))

      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      keys = [:info, :success, :error, :tip, :help, "info", "success", "error", "tip", "help"]

      assert Enum.any?(keys, fn key ->
               value = Phoenix.Flash.get(conn.assigns.flash, key)
               is_binary(value) and String.contains?(value, "teu email estiver no nosso sistema")
             end)

      refute Repo.get_by(Accounts.UserToken, user_id: user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      keys = [:info, :success, :error, :tip, :help, "info", "success", "error", "tip", "help"]

      assert Enum.any?(keys, fn key ->
               value = Phoenix.Flash.get(conn.assigns.flash, key)
               is_binary(value) and String.contains?(value, "teu email estiver no nosso sistema")
             end)

      assert Repo.all(Accounts.UserToken) == []
    end
  end
end
