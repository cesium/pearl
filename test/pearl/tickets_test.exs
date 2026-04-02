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
        priority: "1",
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

  describe "event_meals" do
    alias Pearl.Tickets.EventMeal

    import Pearl.TicketsFixtures

    @invalid_attrs %{date: nil, description: nil, meal_type: nil}

    test "list_event_meals/0 returns all event_meals" do
      event_meal = event_meal_fixture()
      assert Tickets.list_event_meals() == [event_meal]
    end

    test "get_event_meal!/1 returns the event_meal with given id" do
      event_meal = event_meal_fixture()
      assert Tickets.get_event_meal!(event_meal.id) == event_meal
    end

    test "create_event_meal/1 with valid data creates a event_meal" do
      valid_attrs = %{
        date: ~D[2026-04-01],
        description: "some description",
        meal_type: "some meal_type"
      }

      assert {:ok, %EventMeal{} = event_meal} = Tickets.create_event_meal(valid_attrs)
      assert event_meal.date == ~D[2026-04-01]
      assert event_meal.description == "some description"
      assert event_meal.meal_type == "some meal_type"
    end

    test "create_event_meal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tickets.create_event_meal(@invalid_attrs)
    end

    test "update_event_meal/2 with valid data updates the event_meal" do
      event_meal = event_meal_fixture()

      update_attrs = %{
        date: ~D[2026-04-02],
        description: "some updated description",
        meal_type: "some updated meal_type"
      }

      assert {:ok, %EventMeal{} = event_meal} =
               Tickets.update_event_meal(event_meal, update_attrs)

      assert event_meal.date == ~D[2026-04-02]
      assert event_meal.description == "some updated description"
      assert event_meal.meal_type == "some updated meal_type"
    end

    test "update_event_meal/2 with invalid data returns error changeset" do
      event_meal = event_meal_fixture()
      assert {:error, %Ecto.Changeset{}} = Tickets.update_event_meal(event_meal, @invalid_attrs)
      assert event_meal == Tickets.get_event_meal!(event_meal.id)
    end

    test "delete_event_meal/1 deletes the event_meal" do
      event_meal = event_meal_fixture()
      assert {:ok, %EventMeal{}} = Tickets.delete_event_meal(event_meal)
      assert_raise Ecto.NoResultsError, fn -> Tickets.get_event_meal!(event_meal.id) end
    end

    test "change_event_meal/1 returns a event_meal changeset" do
      event_meal = event_meal_fixture()
      assert %Ecto.Changeset{} = Tickets.change_event_meal(event_meal)
    end
  end
end
