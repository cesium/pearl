defmodule Pearl.DiscountCodes do
  @moduledoc """
  The DiscountCodes context.
  """

  import Ecto.Query, warn: false
  alias Pearl.Repo

  alias Pearl.DiscountCodes.DiscountCode

  @doc """
  Returns the list of discount_codes.

  ## Examples

      iex> list_discount_codes()
      [%DiscountCode{}, ...]

  """
  def list_discount_codes(params \\ %{}) do
    DiscountCode
    |> preload(:ticket_types)
    |> Flop.validate_and_run(params, for: DiscountCode)
  end

  @doc """
  Gets a single discount_code.

  Raises `Ecto.NoResultsError` if the Discount code does not exist.

  ## Examples

      iex> get_discount_code!(123)
      %DiscountCode{}

      iex> get_discount_code!(456)
      ** (Ecto.NoResultsError)

  """
  def get_discount_code!(id) do
    DiscountCode
    |> Repo.get!(id)
    |> Repo.preload(:ticket_types)
  end

  @doc """
  Creates a discount_code.

  ## Examples

      iex> create_discount_code(%{field: value})
      {:ok, %DiscountCode{}}

      iex> create_discount_code(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_discount_code(attrs) do
    %DiscountCode{}
    |> Repo.preload(:ticket_types)
    |> DiscountCode.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a discount_code.

  ## Examples

      iex> update_discount_code(discount_code, %{field: new_value})
      {:ok, %DiscountCode{}}

      iex> update_discount_code(discount_code, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_discount_code(%DiscountCode{} = discount_code, attrs) do
    discount_code
    |> Repo.preload(:ticket_types)
    |> DiscountCode.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a discount_code.

  ## Examples

      iex> delete_discount_code(discount_code)
      {:ok, %DiscountCode{}}

      iex> delete_discount_code(discount_code)
      {:error, %Ecto.Changeset{}}

  """
  def delete_discount_code(%DiscountCode{} = discount_code) do
    Repo.delete(discount_code)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking discount_code changes.

  ## Examples

      iex> change_discount_code(discount_code)
      %Ecto.Changeset{data: %DiscountCode{}}

  """
  def change_discount_code(%DiscountCode{} = discount_code, attrs \\ %{}) do
    DiscountCode.changeset(discount_code, attrs)
  end
end
