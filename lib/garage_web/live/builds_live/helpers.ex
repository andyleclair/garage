defmodule GarageWeb.BuildsLive.Helpers do
  @moduledoc ~S"""
  Shared helpers for builds
  """
  alias AshPhoenix.Form
  alias Garage.Mopeds.Manufacturer
  alias Garage.Mopeds.Model
  alias Garage.Mopeds.Carburetor
  alias Garage.Mopeds.Engine
  alias Garage.Mopeds.Clutch
  alias Garage.Mopeds.Exhaust

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

  def manufacturer_options() do
    for manufacturer <- Manufacturer.by_category!(:mopeds),
        into: [],
        do: {manufacturer.name, manufacturer.id}
  end

  # TODO: Load just the manufacturer name instead of the whole thing
  def carburetor_options() do
    for carburetor <- Carburetor.read_all!(load: [:manufacturer]),
        into: [],
        do: {"#{carburetor.manufacturer.name} #{carburetor.name}", carburetor.id}
  end

  def engine_options() do
    for engine <- Engine.read_all!(load: [:manufacturer]),
        into: [],
        do: {"#{engine.manufacturer.name} #{engine.name}", engine.id}
  end

  def clutch_options() do
    for clutch <- Clutch.read_all!(load: [:manufacturer]),
        into: [],
        do: {"#{clutch.manufacturer.name} #{clutch.name}", clutch.id}
  end

  def exhaust_options() do
    for exhaust <- Exhaust.read_all!(load: [:manufacturer]),
        into: [],
        do: {"#{exhaust.manufacturer.name} #{exhaust.name}", exhaust.id}
  end

  def model_options_by_id(manufacturer_id) do
    for model <- Model.by_manufacturer_id!(manufacturer_id), into: [], do: {model.name, model.id}
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
