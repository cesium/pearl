defmodule Mix.Tasks.EarlyBird do
  @moduledoc """
  """
  use Mix.Task
  import Ecto.Query, warn: false

  alias Pearl.Accounts.Attendee
  alias Pearl.Contest
  alias Pearl.Contest.Badge
  alias Pearl.Repo

  def run(_args) do
    Mix.Task.run("app.start")

    ticket_type_ids = [
      "32f84498-0ca5-4060-83d7-b19df52d40c1",
      "d5713977-7243-4aae-9f79-6770a4aadfc4",
      "e2393147-e1e5-4461-bf62-acf35ad69a66"
    ]

    attendees =
      Attendee
      |> join(:inner, [a], u in assoc(a, :user))
      |> join(:inner, [a, u], t in assoc(u, :ticket))
      |> join(:inner, [a, u, t], tt in assoc(t, :ticket_type))
      |> distinct([a, _u, _t, _tt], a.id)
      |> where([_a, _u, t, tt], t.paid and tt.id in ^ticket_type_ids)
      |> preload([_a, u, _t, _tt], user: u)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "Early Bird")

    for attendee <- attendees do
      Mix.shell().info("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee) do
        {:ok, _} -> Mix.shell().info("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> Mix.shell().info("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end
end

Mix.Tasks.EarlyBird.run([])
