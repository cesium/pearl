defmodule Pearl.Activities.CalendarPicture do
  @moduledoc """
  Calendar picture for each day of the event .
  """

  use Pearl.Schema

  @required_fields ~w(date)a
  @optional_fields ~w(image)a

  schema "calendar_pictures" do
    field :date, :date
    field :image, Uploaders.Schedule.Type

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(calendar_picture, attrs) do
    calendar_picture
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def image_changeset(calendar_picture, attrs) do
    calendar_picture
    |> cast_attachments(attrs, [:image])
  end
end
