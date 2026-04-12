defmodule Mix.Tasks.CTF_DAY2 do
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
      "carlinhossss04",
      "gui_rodriguesss08",
      "esteves",
      "joaobarreira05",
      "pdf",
      "alxmra",
      "jess",
      "killian",
      "limwa",
      "pintotomas10",
      "lipe",
      "bacelar",
      "gsarabanda",
      "americosousa",
      "luiscarvalho23",
      "diogomacedo2005",
      "filipa_mont",
      "fcosq",
      "tomaslferreira",
      "2004bdlc",
      "lucasfariapinto",
      "catiaeira",
      "lumafepe",
      "joao_nogueira",
      "coutoo",
      "trator",
      "biokiller134",
      "digazz",
      "rush",
      "rneves05",
      "gabriel_faria"
    ]

    attendees =
      Attendee
      |> join(:inner, [a], u in assoc(a, :user))
      |> where([_a, u], u.handle in handles)
      |> preload([_a, u], user: u)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "CTF - Dia 2")
    redeem_day = ~D[2026-04-11]

    for attendee <- attendees do
      Mix.shell().info("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee, nil, redeem_day) do
        {:ok, _} -> Mix.shell().info("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> Mix.shell().info("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end
end

Mix.Tasks.CTF_DAY2.run([])
