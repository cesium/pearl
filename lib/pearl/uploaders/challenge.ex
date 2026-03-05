defmodule Pearl.Uploaders.Challenge do
  @moduledoc """
  Challenge image uploader.
  """
  use Pearl.Uploader

  alias Pearl.Challenges.Challenge

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .png .svg)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(extension_whitelist(), file_extension)
  end

  def storage_dir(_, {_file, %Challenge{} = challenge}) do
    "uploads/challenges/challenge/#{challenge.id}"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
