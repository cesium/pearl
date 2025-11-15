defmodule Pearl.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :pearl

  alias Pearl.Accounts.Roles.Permissions

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
      name: name,
      email: email,
      password: password,
      handle: handle,
      role_id: role.id
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
