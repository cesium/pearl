defmodule Pearl.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :pearl

  alias Pearl.Accounts.Roles.Permissions

  import Ecto.Query, warn: false

  alias Pearl.Accounts.Attendee
  alias Pearl.Contest
  alias Pearl.Contest.Badge
  alias Pearl.Contest.BadgeRedeem
  alias Pearl.Repo

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def create_root_account(name, email, password, handle, role \\ "Admin") do
    load_app()

    if String.length(password) < 12 do
      raise ArgumentError, "Password must be at least 12 characters long"
    end

    # Fetch all permissions
    permissions = Permissions.all()

    role =
      Pearl.Roles.get_role_by_name(role)
      |> case do
        r when r == nil ->
          Pearl.Roles.create_role(%{name: role, permissions: permissions}) |> elem(1)

        r ->
          r
      end

    # Create user
    Pearl.Accounts.register_staff_user(%{
      "name" => name,
      "email" => email,
      "password" => password,
      "handle" => handle,
      "staff" => %{
        "role_id" => role.id
      }
    })
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    # Many platforms require SSL when connecting to the database
    Application.ensure_all_started(:ssl)
    Application.ensure_loaded(@app)
  end

  def give_early_bird do
    ticket_type_ids = [
      "32f84498-0ca5-4060-83d7-b19df52d40c1",
      "d5713977-7243-4aae-9f79-6770a4aadfc4",
      "e2393147-e1e5-4461-bf62-acf35ad69a66"
    ]

    attendees =
      Attendee
      |> join(:inner, [a], u in assoc(a, :user))
      |> join(:inner, [a, u], t in assoc(u, :ticket))
      |> distinct([a, _u, _t, _tt], a.id)
      |> where([_a, _u, t, tt], t.paid and t.ticket_type_id in ^ticket_type_ids)
      |> preload([_a, u, _t, _tt], user: u)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "Early Bird")

    for attendee <- attendees do
      IO.inspect("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee) do
        {:ok, _} -> IO.inspect("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> IO.inspect("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end

  def give_fcfs do
    attendees =
      BadgeRedeem
      |> join(:inner, [br], a in Attendee, on: br.attendee_id == a.id)
      |> join(:inner, [br, a], b in Badge, on: br.badge_id == b.id)
      |> where([br, a, b], b.name == "Acreditação")
      |> order_by([br, a, b], br.inserted_at)
      |> where([br, a, b], not a.ineligible)
      |> limit(100)
      |> preload(attendee: [:user])
      |> Repo.all()
      |> Enum.map(fn br -> br.attendee end)

    badge = Repo.one(from b in Badge, where: b.name == "First Come, First Served")

    for attendee <- attendees do
      IO.inspect("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee) do
        {:ok, _} -> IO.inspect("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> IO.inspect("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end

  def give_ctf_day1 do
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
      |> join(:inner, [a], u in assoc(a, :user))
      |> where([_a, u], u.handle in ^handles)
      |> preload([_a, u], user: u)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "CTF - Dia 1")
    redeem_day = ~D[2026-04-10]

    for attendee <- attendees do
      IO.inspect("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee, nil, redeem_day) do
        {:ok, _} -> IO.inspect("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> IO.inspect("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end

  def give_ctf_day2 do
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
      |> where([_a, u], u.handle in ^handles)
      |> preload([_a, u], user: u)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "CTF - Dia 2")
    redeem_day = ~D[2026-04-11]

    for attendee <- attendees do
      IO.inspect("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee, nil, redeem_day) do
        {:ok, _} -> IO.inspect("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> IO.inspect("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end

  def give_ctf_day3 do
    handles = [
      "alxmra",
      "joaobarreira05",
      "gsarabanda",
      "esteves",
      "gui_rodriguesss08",
      "limwa",
      "carlinhossss04",
      "filipa_mont",
      "lumafepe",
      "tabo",
      "Killian",
      "digazz",
      "rneves05"
    ]

    attendees =
      Attendee
      |> join(:inner, [a], u in assoc(a, :user))
      |> where([_a, u], u.handle in ^handles)
      |> preload([_a, u], user: u)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "CTF - Dia 3")
    redeem_day = ~D[2026-04-12]

    for attendee <- attendees do
      IO.inspect("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee, nil, redeem_day) do
        {:ok, _} -> IO.inspect("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> IO.inspect("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end

  def give_prog_contest_day1 do
    handles = [
      "esteves",
      "vcnt",
      "filipa_mont",
      "diogomacedo2005",
      "limwa",
      "lumafepe"
    ]

    attendees =
      Attendee
      |> join(:inner, [a], u in assoc(a, :user))
      |> where([_a, u], u.handle in ^handles)
      |> preload([_a, u], user: u)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "Concurso de Programação - Desafio 1")
    redeem_day = ~D[2026-04-10]

    for attendee <- attendees do
      IO.inspect("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee, nil, redeem_day) do
        {:ok, _} -> IO.inspect("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> IO.inspect("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end

  def give_prog_contest_day2 do
    handles = [
      "esteves",
      "lumafepe",
      "diogomacedo2005",
      "limwa",
      "vcnt",
      "filipa_mont"
    ]

    attendees =
      Attendee
      |> join(:inner, [a], u in assoc(a, :user))
      |> where([_a, u], u.handle in ^handles)
      |> preload([_a, u], user: u)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "Concurso de Programação - Desafio 2")
    redeem_day = ~D[2026-04-11]

    for attendee <- attendees do
      IO.inspect("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee, nil, redeem_day) do
        {:ok, _} -> IO.inspect("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> IO.inspect("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end

  def give_pitches do
    handles = [
      "tomaslferreira",
      "lucasfariapinto",
      "filipe",
      "ivsop",
      "pedrocarvalho",
      "rui",
      "diogo_rodrigues"
    ]

    attendees =
      Attendee
      |> join(:inner, [a], u in assoc(a, :user))
      |> where([_a, u], u.handle in ^handles)
      |> preload([_a, u], user: u)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "Yapper")
    redeem_day = ~D[2026-04-11]

    for attendee <- attendees do
      IO.inspect("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee, nil, redeem_day) do
        {:ok, _} -> IO.inspect("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> IO.inspect("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end
end
