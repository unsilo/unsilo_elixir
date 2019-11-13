defmodule Unsilo.PlacePic do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original, :thumb, :medium]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  # def validate({file, _}) do
  #   ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  # end

  def transform(:thumb, _) do
    {:convert,
     "-auto-orient -strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  end

  def transform(:medium, _) do
    {:convert,
     "-auto-orient -strip -thumbnail 500x500^ -gravity center -extent 500x500^ -format png", :png}
  end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  def storage_dir(version, {_file, scope}) do
    "uploads/locations/place/#{scope.id}/#{version}"
  end

  def default_url(_version, _scope) do
    "/defaults/place_default.png"
  end
end
