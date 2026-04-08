defmodule Pearl.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :pearl

  import Ecto.Query, warn: false
  alias Pearl.Repo

  alias Pearl.Contest
  alias Pearl.Contest.{Badge, BadgeRedeem}
  alias Pearl.Accounts.Attendee
  alias Pearl.Accounts.Roles.Permissions

    def run_gold_mine do
    golds = ["Accenture", "AgentifAI", "Uphold", "Retail Consult"]

    len = Kernel.length(golds)

    attendees =
      BadgeRedeem
      |> join(:inner, [br], a in Attendee, on: br.attendee_id == a.id)
      |> join(:inner, [br, a], b in Badge, on: br.badge_id == b.id)
      |> where([br, a, b], b.name in ^golds)
      |> group_by([br, a, b], a.id)
      |> having([br, a, b], count(br.id) == ^len)
      |> select([br, a, b], a)
      |> subquery()
      |> preload(:user)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "Gold Mine")

    for attendee <- attendees do
      IO.puts("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee) do
        {:ok, _} -> IO.puts("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> IO.puts("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end

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
end
