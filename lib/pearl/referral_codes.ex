defmodule Pearl.Referrals do
  @doc """
    The context for the Referral Codes
  """

  use Pearl.Context

  alias Pearl.Repo
  alias Pearl.Referrals.Referral

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

  def update_referral(%Referral{} = referral, attrs) do
    referral
    |> Referral.changeset(attrs)
    |> Repo.update()
  end

  def delete_referral(%Referral{} = referral) do
    Repo.delete(referral)
  end

end
