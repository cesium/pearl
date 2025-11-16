defmodule Pearl.Accounts.Staff do
  @moduledoc """
  An event staff.
  """
  use Pearl.Schema

  alias Pearl.Accounts.User

  @required_fields ~w(user_id role_id)a
  @optional_fields ~w()a

  schema "staffs" do
    belongs_to :user, User
    belongs_to :role, Pearl.Accounts.Role

    timestamps(type: :utc_datetime)
  end

  def changeset(staff, attrs) do
    staff
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
