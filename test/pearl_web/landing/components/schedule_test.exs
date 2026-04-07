defmodule PearlWeb.Landing.Components.ScheduleTest do
  use ExUnit.Case, async: true

  alias PearlWeb.Landing.Components.Schedule

  describe "group_activities_in_blocks/1" do
    test "groups and orders activities by start/end and category" do
      activities = [
        %{id: 1, time_start: ~T[14:00:00], time_end: ~T[15:00:00], category: %{name: "Talk"}},
        %{id: 2, time_start: ~T[15:00:00], time_end: ~T[16:00:00], category: %{name: "Workshop"}},
        %{id: 3, time_start: ~T[14:00:00], time_end: ~T[16:00:00], category: %{name: "Gameshow"}},
        %{id: 4, time_start: ~T[14:00:00], time_end: ~T[15:00:00], category: %{name: "Workshop"}},
        %{id: 5, time_start: ~T[14:00:00], time_end: ~T[15:00:00], category: %{name: "Talk"}}
      ]

      grouped = Schedule.group_activities_in_blocks(activities)

      assert grouped == [
               [
                 %{
                   id: 1,
                   time_start: ~T[14:00:00],
                   time_end: ~T[15:00:00],
                   category: %{name: "Talk"}
                 },
                 %{
                   id: 5,
                   time_start: ~T[14:00:00],
                   time_end: ~T[15:00:00],
                   category: %{name: "Talk"}
                 },
                 %{
                   id: 4,
                   time_start: ~T[14:00:00],
                   time_end: ~T[15:00:00],
                   category: %{name: "Workshop"}
                 }
               ],
               [
                 %{
                   id: 3,
                   time_start: ~T[14:00:00],
                   time_end: ~T[16:00:00],
                   category: %{name: "Gameshow"}
                 }
               ],
               [
                 %{
                   id: 2,
                   time_start: ~T[15:00:00],
                   time_end: ~T[16:00:00],
                   category: %{name: "Workshop"}
                 }
               ]
             ]
    end

    test "break gets its own block and appears before other activities at the same start time" do
      activities = [
        %{id: 1, time_start: ~T[14:00:00], time_end: ~T[14:30:00], category: %{name: "Talk"}},
        %{id: 2, time_start: ~T[14:00:00], time_end: ~T[14:30:00], category: %{name: "Break"}},
        %{id: 3, time_start: ~T[14:00:00], time_end: ~T[14:30:00], category: %{name: "Workshop"}}
      ]

      grouped = Schedule.group_activities_in_blocks(activities)

      assert grouped == [
               [
                 %{
                   id: 2,
                   time_start: ~T[14:00:00],
                   time_end: ~T[14:30:00],
                   category: %{name: "Break"}
                 }
               ],
               [
                 %{
                   id: 1,
                   time_start: ~T[14:00:00],
                   time_end: ~T[14:30:00],
                   category: %{name: "Talk"}
                 },
                 %{
                   id: 3,
                   time_start: ~T[14:00:00],
                   time_end: ~T[14:30:00],
                   category: %{name: "Workshop"}
                 }
               ]
             ]
    end

    test "multiple breaks each get their own block in chronological order" do
      activities = [
        %{id: 1, time_start: ~T[13:00:00], time_end: ~T[14:00:00], category: %{name: "Break"}},
        %{id: 2, time_start: ~T[10:30:00], time_end: ~T[11:00:00], category: %{name: "Break"}},
        %{id: 3, time_start: ~T[10:30:00], time_end: ~T[11:00:00], category: %{name: "Talk"}}
      ]

      grouped = Schedule.group_activities_in_blocks(activities)

      assert grouped == [
               [
                 %{
                   id: 2,
                   time_start: ~T[10:30:00],
                   time_end: ~T[11:00:00],
                   category: %{name: "Break"}
                 }
               ],
               [
                 %{
                   id: 3,
                   time_start: ~T[10:30:00],
                   time_end: ~T[11:00:00],
                   category: %{name: "Talk"}
                 }
               ],
               [
                 %{
                   id: 1,
                   time_start: ~T[13:00:00],
                   time_end: ~T[14:00:00],
                   category: %{name: "Break"}
                 }
               ]
             ]
    end
  end
end
