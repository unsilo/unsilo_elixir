defmodule Unsilo.Archive do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  # def validate({file, _}) do
  #   ~w(.pdf .zip) |> Enum.member?(Path.extname(file.file_name))
  # end

  # Override the persisted filenames:
  def filename(version, _) do
    "#{version}"
  end

  def storage_dir(_version, {_file, scope}) do
    "uploads/feeds/archive/#{scope.id}"
  end

  def default_url(_version, _scope) do
    "/defaults/parking_default.png"
  end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: MIME.from_path(file.file_name)]
  # end
end
