defmodule Pearl.DiscountCodesTest do
  use Pearl.DataCase

  alias Pearl.DiscountCodes

  describe "discount_codes" do
    alias Pearl.DiscountCodes.DiscountCode

    import Pearl.DiscountCodesFixtures

    @invalid_attrs %{active: nil, code: nil, amount: nil, usage_limit: nil}

    test "list_discount_codes/0 returns all discount_codes" do
      discount_code = discount_code_fixture()
      assert {:ok, {discount_codes, _meta}} = DiscountCodes.list_discount_codes()
      assert discount_code in discount_codes
    end

    test "get_discount_code!/1 returns the discount_code with given id" do
      discount_code = discount_code_fixture()
      assert DiscountCodes.get_discount_code!(discount_code.id) == discount_code
    end

    test "create_discount_code/1 with valid data creates a discount_code" do
      valid_attrs = %{active: true, code: "some code", amount: 42, usage_limit: 1}

      assert {:ok, %DiscountCode{} = discount_code} =
               DiscountCodes.create_discount_code(valid_attrs)

      assert discount_code.active == true
      assert discount_code.code == "some code"
      assert discount_code.amount == 42
    end

    test "create_discount_code/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DiscountCodes.create_discount_code(@invalid_attrs)
    end

    test "update_discount_code/2 with valid data updates the discount_code" do
      discount_code = discount_code_fixture()
      update_attrs = %{active: false, code: "some updated code", amount: 43, usage_limit: 2}

      assert {:ok, %DiscountCode{} = discount_code} =
               DiscountCodes.update_discount_code(discount_code, update_attrs)

      assert discount_code.active == false
      assert discount_code.code == "some updated code"
      assert discount_code.amount == 43
    end

    test "update_discount_code/2 with invalid data returns error changeset" do
      discount_code = discount_code_fixture()

      assert {:error, %Ecto.Changeset{}} =
               DiscountCodes.update_discount_code(discount_code, @invalid_attrs)

      assert discount_code == DiscountCodes.get_discount_code!(discount_code.id)
    end

    test "delete_discount_code/1 deletes the discount_code" do
      discount_code = discount_code_fixture()
      assert {:ok, %DiscountCode{}} = DiscountCodes.delete_discount_code(discount_code)

      assert_raise Ecto.NoResultsError, fn ->
        DiscountCodes.get_discount_code!(discount_code.id)
      end
    end

    test "change_discount_code/1 returns a discount_code changeset" do
      discount_code = discount_code_fixture()
      assert %Ecto.Changeset{} = DiscountCodes.change_discount_code(discount_code)
    end
  end
end
