defmodule Mix.Tasks.CTF_DAY1 do
  @moduledoc """
  """
  use Mix.Task
  import Ecto.Query, warn: false

  alias Pearl.Accounts
  alias Pearl.Accounts.Attendee
  alias Pearl.Contest
  alias Pearl.Contest.Badge
  alias Pearl.Contest.BadgeRedeem
  alias Pearl.Repo

  def run(_args) do
    Mix.Task.run("app.start")

    handles = [
      "vcnt",
      "shieda",
      "alxmra",
      "rafael_torrinhas",
      "gsarabanda",
      "sleepyy",
      "digazz",
      "rneves05",
      "ixsb",
      "esteves",
      "carlinhossss04",
      "pergih",
      "pdf",
      "gui_rodriguesss08",
      "limwa",
      "lipe",
      "pintotomas10",
      "loren_silva",
      "inesmatos21",
      "patriciabastos",
      "rafa",
      "edinh0z",
      "erturto"
    ]

    attendees =
      Attendee
      |> where([a], a.handle in handles)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "CTF - Dia 1")

    for attendee <- attendees do
      Mix.shell().info("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee) do
        {:ok, _} -> Mix.shell().info("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> Mix.shell().info("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end
end

Mix.Tasks.CTF_DAY1.run([])
