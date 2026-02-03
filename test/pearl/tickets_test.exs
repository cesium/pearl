defmodule Pearl.TicketsTest do
  use Pearl.DataCase

  alias Pearl.Tickets

  describe "perks" do
    alias Pearl.Tickets.Perk

    import Pearl.TicketsFixtures

    @invalid_attrs %{name: nil, description: nil, color: nil, icon: nil, active: nil}

    test "list_perks/0 returns all perks" do
      perk = perk_fixture()
      assert Tickets.list_perks() == [perk]
    end

    test "get_perk!/1 returns the perk with given id" do
      perk = perk_fixture()
      assert Tickets.get_perk!(perk.id) == perk
    end

    test "create_perk/1 with valid data creates a perk" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        color: "some color",
        icon: "some icon",
        active: true
      }

      assert {:ok, %Perk{} = perk} = Tickets.create_perk(valid_attrs)
      assert perk.name == "some name"
      assert perk.description == "some description"
      assert perk.color == "some color"
      assert perk.icon == "some icon"
      assert perk.active == true
    end

    test "create_perk/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tickets.create_perk(@invalid_attrs)
    end

    test "update_perk/2 with valid data updates the perk" do
      perk = perk_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        color: "some updated color",
        icon: "some updated icon",
        active: true
      }

      assert {:ok, %Perk{} = perk} = Tickets.update_perk(perk, update_attrs)
      assert perk.name == "some updated name"
      assert perk.description == "some updated description"
      assert perk.color == "some updated color"
      assert perk.icon == "some updated icon"
      assert perk.active == true
    end

    test "update_perk/2 with invalid data returns error changeset" do
      perk = perk_fixture()
      assert {:error, %Ecto.Changeset{}} = Tickets.update_perk(perk, @invalid_attrs)
      assert perk == Tickets.get_perk!(perk.id)
    end

    test "delete_perk/1 deletes the perk" do
      perk = perk_fixture()
      assert {:ok, %Perk{}} = Tickets.delete_perk(perk)
      assert_raise Ecto.NoResultsError, fn -> Tickets.get_perk!(perk.id) end
    end

    test "change_perk/1 returns a perk changeset" do
      perk = perk_fixture()
      assert %Ecto.Changeset{} = Tickets.change_perk(perk)
    end
  end
end
