defmodule Pearl.Repo.Seeds.Roles do
  alias Pearl.Accounts.Role
  alias Pearl.Accounts.Roles.Permissions
  alias Pearl.Repo
  alias Pearl.Roles

  def run do
    case Roles.list_roles() do
      [] ->
        seed_roles()
      _  ->
        Mix.shell().error("Found roles, aborting seeding roles.")
    end
  end

  def seed_roles do
    permissions = Permissions.all()

    roles = [
      %{
        name: "Admin",
        permissions: permissions
      }
    ]

    Enum.each(roles, fn role ->
      role = Role.changeset(%Role{}, role)
      Repo.insert(role)
    end)
  end
end

Pearl.Repo.Seeds.Roles.run()
