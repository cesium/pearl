defmodule Pearl.Uploaders.LockerItems do
  @moduledoc """
  Locker item image uploader.
  """
  use Pearl.Uploader

  alias Pearl.Lockers.LockerItem

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .png .heic .webp)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %LockerItem{} = item}) do
    "uploads/lockers/items/#{item.id}"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
