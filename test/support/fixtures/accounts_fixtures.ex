defmodule Pearl.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pearl.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def valid_phone_number, do: "987654321"
  def unique_handle, do: "user#{System.unique_integer([:positive])}"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      "name" => "John Doe",
      "handle" => unique_handle(),
      "email" => unique_user_email(),
      "password" => valid_user_password(),
      "phone" => valid_phone_number()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, %{user: user}} =
      attrs
      |> valid_user_attributes()
      |> Pearl.Accounts.register_attendee_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")

    # Try both html_body and text_body since Phoenix.Swoosh can use either
    body = captured_email.html_body || captured_email.text_body

    [_, token | _] = String.split(body || "", "[TOKEN]")
    token
  end

  @doc """
  Generate a credential.
  """
  def credential_fixture(attrs \\ %{}) do
    {:ok, credential} =
      attrs
      |> Enum.into(%{})
      |> Pearl.Accounts.create_credential()

    credential
  end

  @doc """
  Generate an attendee.
  """
  def attendee_fixture(attrs \\ %{}) do
    {:ok, attendee} =
      attrs
      |> Enum.into(%{user_id: user_fixture().id})
      |> Pearl.Accounts.create_attendee()

    attendee
  end
end
