defmodule Pearl.Uploaders.Speaker do
  @moduledoc """
  Speaker image uploader.
  """
  use Pearl.Uploader

  alias Pearl.Activities.Speaker

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .png)

  @ratio_target 1.0
  @ratio_tolerance 0.2

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    with {:ok, image} <- Image.open(file.path),
         {w, h, _} <- Image.shape(image),
         true <- square_ratio?(w, h) do
      true and Enum.member?(extension_whitelist(), file_extension)
    else
      _ -> false
    end
  end

  def storage_dir(_, {_file, %Speaker{} = speaker}) do
    "uploads/activities/speakers/#{speaker.id}"
  end

  def filename(version, _) do
    version
  end

  def square_ratio?(width, height) do
    ratio = width / height
    abs(ratio - @ratio_target) <= @ratio_tolerance
  end

  def extension_whitelist do
    @extension_whitelist
  end
end
