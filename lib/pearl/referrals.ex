defmodule Pearl.Referrals do
  @moduledoc """
  The context for the Referrals
  """

  use Pearl.Context

  alias Pearl.Referrals.Referral
  alias Pearl.Repo

  def list_referrals do
    Repo.all(Referral)
  end

  def list_referrals(opts) when is_list(opts) do
    Referral
    |> apply_filters(opts)
    |> Repo.all()
  end

  def list_referrals(params) do
    Referral
    |> Flop.validate_and_run(params, for: Referral)
  end

  def get_referral(id) do
    Repo.get(Referral, id)
  end

  def get_referral_by_code(code) when is_binary(code) do
    Repo.get_by(Referral, code: code)
  end

  def change_referral(%Referral{} = referral, attrs \\ %{}) do
    Referral.changeset(referral, attrs)
  end

  def update_referral(%Referral{} = referral, attrs) do
    referral
    |> Referral.changeset(attrs)
    |> Repo.update()
  end

  def create_referral(attrs \\ %{}) do
    %Referral{}
    |> Referral.changeset(attrs)
    |> Repo.insert()
  end

  def delete_referral(%Referral{} = referral) do
    Repo.delete(referral)
  end

  def archive_referral(%Referral{} = referral) do
    referral
    |> Referral.changeset(%{active: false})
    |> Repo.update()
  end

  def unarchive_referral(%Referral{} = referral) do
    referral
    |> Referral.changeset(%{active: true})
    |> Repo.update()
  end
end
