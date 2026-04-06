defmodule Pearl.Activities.ActivityCategory do
  @moduledoc """
  Categories for activities.
  """
  use Pearl.Schema

  @required_fields ~w(name)a
  @valid_names ~w(Talk Pitch Gameshow Workshop Break)

  schema "activity_categories" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity_category, attrs) do
    activity_category
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:name, @valid_names)
  end
end
