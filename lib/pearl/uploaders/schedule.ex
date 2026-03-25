defmodule Pearl.Uploaders.Schedule do
  @moduledoc """
  Calendar image uploader.
  """
  use Pearl.Uploader

  alias Pearl.Activities.CalendarPicture

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %CalendarPicture{} = calendar_picture}) do
    "uploads/activities/calendar_pictures/#{calendar_picture.id}"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
