defmodule Pearl.LockersTest do
  use Pearl.DataCase

  alias Pearl.Lockers

  describe "lockers" do
    alias Pearl.Lockers.Locker

    import Pearl.LockersFixtures

    @invalid_attrs %{number: nil}

    test "list_lockers/0 returns all lockers" do
      locker = locker_fixture()
      assert Lockers.list_lockers() == [locker]
    end

    test "get_locker!/1 returns the locker with given id" do
      locker = locker_fixture()
      assert Lockers.get_locker!(locker.id) == locker
    end

    test "create_locker/1 with valid data creates a locker" do
      valid_attrs = %{number: 42}

      assert {:ok, %Locker{} = locker} = Lockers.create_locker(valid_attrs)
      assert locker.number == 42
    end

    test "create_locker/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lockers.create_locker(@invalid_attrs)
    end

    test "update_locker/2 with valid data updates the locker" do
      locker = locker_fixture()
      update_attrs = %{number: 43}

      assert {:ok, %Locker{} = locker} = Lockers.update_locker(locker, update_attrs)
      assert locker.number == 43
    end

    test "update_locker/2 with invalid data returns error changeset" do
      locker = locker_fixture()
      assert {:error, %Ecto.Changeset{}} = Lockers.update_locker(locker, @invalid_attrs)
      assert locker == Lockers.get_locker!(locker.id)
    end

    test "delete_locker/1 deletes the locker" do
      locker = locker_fixture()
      assert {:ok, %Locker{}} = Lockers.delete_locker(locker)
      assert_raise Ecto.NoResultsError, fn -> Lockers.get_locker!(locker.id) end
    end

    test "change_locker/1 returns a locker changeset" do
      locker = locker_fixture()
      assert %Ecto.Changeset{} = Lockers.change_locker(locker)
    end
  end

  describe "locker_items" do
    alias Pearl.Lockers.LockerItem

    import Pearl.LockersFixtures

    @invalid_attrs %{name: nil, description: nil, attendee_locker_id: nil}

    test "list_locker_items/0 returns all locker_items" do
      locker_item = locker_item_fixture()
      assert Lockers.list_locker_items() == [locker_item]
    end

    test "get_locker_item!/1 returns the locker_item with given id" do
      locker_item = locker_item_fixture()
      assert Lockers.get_locker_item!(locker_item.id) == locker_item
    end

    test "create_locker_item/1 with valid data creates a locker_item" do
      attendee_locker = attendee_locker_fixture()

      valid_attrs = %{
        attendee_locker_id: attendee_locker.id,
        name: "some name",
        description: "some description",
        stored: true,
        withdrawn_at: ~U[2026-04-02 23:33:00Z]
      }

      assert {:ok, %LockerItem{} = locker_item} = Lockers.create_locker_item(valid_attrs)
      assert locker_item.name == "some name"
      assert locker_item.description == "some description"
      assert locker_item.stored == true
      assert locker_item.withdrawn_at == ~U[2026-04-02 23:33:00Z]
      assert locker_item.attendee_locker_id == attendee_locker.id
    end

    test "create_locker_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lockers.create_locker_item(@invalid_attrs)
    end

    test "update_locker_item/2 with valid data updates the locker_item" do
      locker_item = locker_item_fixture()
      attendee_locker = attendee_locker_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        attendee_locker_id: attendee_locker.id,
        stored: false,
        withdrawn_at: ~U[2026-04-03 23:33:00Z]
      }

      assert {:ok, %LockerItem{} = locker_item} =
               Lockers.update_locker_item(locker_item, update_attrs)

      assert locker_item.name == "some updated name"
      assert locker_item.description == "some updated description"
      assert locker_item.stored == false
      assert locker_item.withdrawn_at == ~U[2026-04-03 23:33:00Z]
      assert locker_item.attendee_locker_id == attendee_locker.id
    end

    test "update_locker_item/2 with invalid data returns error changeset" do
      locker_item = locker_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Lockers.update_locker_item(locker_item, @invalid_attrs)
      assert locker_item == Lockers.get_locker_item!(locker_item.id)
    end

    test "delete_locker_item/1 deletes the locker_item" do
      locker_item = locker_item_fixture()
      assert {:ok, %LockerItem{}} = Lockers.delete_locker_item(locker_item)
      assert_raise Ecto.NoResultsError, fn -> Lockers.get_locker_item!(locker_item.id) end
    end

    test "change_locker_item/1 returns a locker_item changeset" do
      locker_item = locker_item_fixture()
      assert %Ecto.Changeset{} = Lockers.change_locker_item(locker_item)
    end
  end

  describe "attendee_lockers" do
    alias Pearl.Lockers.AttendeeLocker

    import Pearl.LockersFixtures

    @invalid_attrs %{active: nil, attendee_id: nil, locker_id: nil}

    test "list_attendee_lockers/0 returns all attendee_lockers" do
      attendee_locker = attendee_locker_fixture()
      assert Lockers.list_attendee_lockers() == [attendee_locker]
    end

    test "get_attendee_locker!/1 returns the attendee_locker with given id" do
      attendee_locker = attendee_locker_fixture()
      assert Lockers.get_attendee_locker!(attendee_locker.id) == attendee_locker
    end

    test "create_attendee_locker/1 with valid data creates a attendee_locker" do
      attendee = Pearl.AccountsFixtures.attendee_fixture()
      locker = locker_fixture()

      valid_attrs = %{
        active: true,
        attendee_id: attendee.id,
        locker_id: locker.id
      }

      assert {:ok, %AttendeeLocker{} = attendee_locker} =
               Lockers.create_attendee_locker(valid_attrs)

      assert attendee_locker.active == true
      assert attendee_locker.attendee_id == attendee.id
      assert attendee_locker.locker_id == locker.id
    end

    test "create_attendee_locker/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lockers.create_attendee_locker(@invalid_attrs)
    end

    test "update_attendee_locker/2 with valid data updates the attendee_locker" do
      attendee_locker = attendee_locker_fixture()
      attendee = Pearl.AccountsFixtures.attendee_fixture()
      locker = locker_fixture()

      update_attrs = %{
        active: false,
        attendee_id: attendee.id,
        locker_id: locker.id
      }

      assert {:ok, %AttendeeLocker{} = attendee_locker} =
               Lockers.update_attendee_locker(attendee_locker, update_attrs)

      assert attendee_locker.active == false
      assert attendee_locker.attendee_id == attendee.id
      assert attendee_locker.locker_id == locker.id
    end

    test "update_attendee_locker/2 with invalid data returns error changeset" do
      attendee_locker = attendee_locker_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Lockers.update_attendee_locker(attendee_locker, @invalid_attrs)

      assert attendee_locker == Lockers.get_attendee_locker!(attendee_locker.id)
    end

    test "delete_attendee_locker/1 deletes the attendee_locker" do
      attendee_locker = attendee_locker_fixture()
      assert {:ok, %AttendeeLocker{}} = Lockers.delete_attendee_locker(attendee_locker)
      assert_raise Ecto.NoResultsError, fn -> Lockers.get_attendee_locker!(attendee_locker.id) end
    end

    test "change_attendee_locker/1 returns a attendee_locker changeset" do
      attendee_locker = attendee_locker_fixture()
      assert %Ecto.Changeset{} = Lockers.change_attendee_locker(attendee_locker)
    end
  end
end
