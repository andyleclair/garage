defmodule GarageWeb.BuildsLive.Helpers do
  @moduledoc ~S"""
  Shared helpers for builds
  """
  alias AshPhoenix.Form

  def form_manufacturer_id(form) do
    case Form.value(form, :manufacturer_id) do
      "" ->
        nil

      nil ->
        nil

      manufacturer_id ->
        manufacturer_id
    end
  end

  def year_options() do
    2023..1900 |> Enum.to_list()
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:too_many_files), do: "You have selected too many files"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  def bucket, do: Application.get_env(:garage, :upload_bucket)

  def upload_path(%Phoenix.LiveView.UploadEntry{client_name: name}) do
    "/garage/builds/uploads/#{Ash.UUID.generate()}-#{name}"
  end

  def public_path(upload_path) do
    "#{public_root()}#{upload_path}"
  end

  def public_root, do: Application.get_env(:garage, :public_image_root)

  # stolen from Liveview internals 
  def random_id do
    "build-img-"
    |> Kernel.<>(random_encoded_bytes())
    |> String.replace(["/", "+"], "-")
  end

  def random_encoded_bytes do
    binary = :crypto.strong_rand_bytes(32)

    Base.url_encode64(binary)
  end
end
