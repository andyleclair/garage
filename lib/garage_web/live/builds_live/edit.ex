defmodule GarageWeb.BuildsLive.Edit do
  require Logger
  use GarageWeb, :live_view

  alias AshPhoenix.Form
  alias ExAws.S3
  alias Garage.Builds.Build
  alias Garage.Mopeds.Manufacturer
  alias Garage.Mopeds.Model
  alias Garage.Mopeds.Carburetor
  alias Garage.Mopeds.Engine
  alias Garage.Mopeds.Clutch
  alias Garage.Mopeds.Exhaust
  alias Garage.Mopeds.Ignition

  import GarageWeb.BuildsLive.Helpers

  @impl true
  def mount(%{"build" => slug}, _session, %{assigns: assigns} = socket) do
    build = Build.get_by_slug!(slug)

    if Build.can_update?(assigns.current_user, build) do
      form = Form.for_action(build, :update, actor: assigns.current_user)

      year_options = year_options()
      manufacturer_options = manufacturer_options()
      carburetor_options = carburetor_options()
      engine_options = engine_options()
      clutch_options = clutch_options()
      exhaust_options = exhaust_options()
      ignition_options = ignition_options()

      # if we already have a manufacturer set, show the model dropdown
      model_options =
        if manufacturer_id = form_manufacturer_id(form) do
          model_options_by_id(manufacturer_id)
        else
          nil
        end

      images = build.image_urls |> Enum.map(fn url -> {random_id(), url} end)

      {:ok,
       socket
       |> assign(:title, "Edit Build")
       |> assign(:build, build)
       |> assign(:manufacturer_options, manufacturer_options)
       |> assign(:images, images)
       |> assign(:uploaded_images, [])
       |> assign(:images_to_delete, [])
       |> assign(:model_options, model_options)
       |> assign(:carburetor_options, carburetor_options)
       |> assign(:engine_options, engine_options)
       |> assign(:clutch_options, clutch_options)
       |> assign(:exhaust_options, exhaust_options)
       |> assign(:ignition_options, ignition_options)
       |> assign(:year_options, year_options)
       |> assign_form(form)
       |> allow_upload(:image_urls,
         accept: ~w(.jpg .jpeg .webp .png),
         max_entries: 10,
         external: &presign_upload/2
       )}
    else
      Logger.error("Unauthorized access by #{assigns.current_user} trying to edit #{slug}")

      {:ok,
       socket
       |> put_flash(:error, "FORBIDDEN! This Action Has Been Logged 😈")
       |> push_navigate(to: ~p"/")}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image_urls, ref)}
  end

  @impl true
  def handle_event("delete-image", %{"ref" => ref}, socket) do
    {{^ref, url}, rest_images} = List.keytake(socket.assigns.images, ref, 0)

    {:noreply,
     socket
     |> assign(:images, rest_images)
     |> assign(:images_to_delete, [url | socket.assigns.images_to_delete])}
  end

  def handle_event("reposition", %{"new" => new_idx, "old" => old_idx}, socket) do
    new_images = Enum.slide(socket.assigns.images, old_idx, new_idx)
    {:noreply, assign(socket, :images, new_images)}
  end

  # Liveselect boilerplate. We do a little codegen
  for select <- [
        "manufacturer",
        "model",
        "carburetor",
        "engine",
        "clutch",
        "exhaust",
        "ignition",
        "forks",
        "wheels"
      ] do
    @impl true
    def handle_event(
          "live_select_change",
          %{"id" => id, "text" => text, "field" => "form_" <> unquote(select) <> "_id"},
          socket
        ) do
      options =
        search_options(
          Map.get(socket.assigns, String.to_existing_atom(unquote(select) <> "_options")),
          text
        )

      send_update(LiveSelect.Component, options: options, id: id)

      {:noreply, socket}
    end

    @impl true
    def handle_event("set-default", %{"id" => "form_" <> unquote(select) <> _ = id}, socket) do
      send_update(LiveSelect.Component,
        options: Map.get(socket.assigns, String.to_existing_atom(unquote(select) <> "_options")),
        id: id
      )

      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)

    socket =
      if manufacturer_id = form_manufacturer_id(form) do
        assign(socket, :model_options, model_options_by_id(manufacturer_id))
      else
        socket
      end

    {:noreply, assign_form(socket, form)}
  end

  @impl true
  def handle_event(
        "save",
        %{"form" => form},
        %{
          assigns: %{images: images, images_to_delete: images_to_delete}
        } = socket
      ) do
    uploaded_files = socket.assigns.uploaded_images

    :ok = async_delete_images(images_to_delete)

    image_urls = for {_ref, img} <- images, do: img

    image_urls = (image_urls -- images_to_delete) ++ uploaded_files
    form = Map.put(form, :image_urls, image_urls)

    save_build(socket, form)
  end

  # Handle not having to deal with images
  @impl true
  def handle_event("save", %{"form" => params}, socket) do
    save_build(socket, params)
  end

  defp save_build(socket, params) do
    case Form.submit(socket.assigns.form, params: params) do
      {:ok, build} ->
        {:noreply,
         socket
         |> put_flash(:info, "Build updated successfully")
         |> push_navigate(to: ~p"/builds/#{build.slug}")}

      {:error, form} ->
        {:noreply, assign_form(socket, form)}
    end
  end

  def manufacturer_options() do
    for manufacturer <- Manufacturer.by_category!(:mopeds),
        into: [],
        do: {manufacturer.name, manufacturer.id}
  end

  def model_options_by_id(manufacturer_id) do
    for model <- Model.by_manufacturer_id!(manufacturer_id), into: [], do: {model.name, model.id}
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

  def ignition_options() do
    for ignition <- Ignition.read_all!(load: [:manufacturer]),
        into: [],
        do: {"#{ignition.manufacturer.name} #{ignition.name}", ignition.id}
  end

  defp presign_upload(entry, socket) do
    config = ExAws.Config.new(:s3)
    key = upload_path(socket.assigns.current_user, socket.assigns.build, entry)

    {:ok, url} =
      ExAws.S3.presigned_url(config, :put, bucket(), key,
        expires_in: 3600,
        query_params: [{"Content-Type", entry.client_type}]
      )

    socket =
      assign(socket, :uploaded_images, socket.assigns.uploaded_images ++ [public_path(key)])

    {:ok, %{uploader: "S3", key: key, url: url}, socket}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:external_client_failure), do: "External client failure"

  defp bucket, do: Application.get_env(:garage, :upload_bucket)

  defp upload_path(user, build, %Phoenix.LiveView.UploadEntry{client_name: name}) do
    "/garage/users/#{user.username}/builds/#{build.name}/uploads/#{Ash.UUID.generate()}-#{name}"
  end

  defp public_path(upload_path) do
    "#{public_root()}#{upload_path}"
  end

  defp public_root, do: Application.get_env(:garage, :public_image_root)

  # stolen from Liveview internals 
  defp random_id do
    "build-img-"
    |> Kernel.<>(random_encoded_bytes())
    |> String.replace(["/", "+"], "-")
  end

  defp random_encoded_bytes do
    binary = :crypto.strong_rand_bytes(32)

    Base.url_encode64(binary)
  end

  defp async_delete_images(images_to_delete) do
    Task.Supervisor.async_stream_nolink(Garage.TaskSupervisor, images_to_delete, fn img ->
      with %URI{path: path} <- URI.parse(img) do
        bucket()
        |> S3.delete_object(path)
        |> ExAws.request!()
      end
    end)
    |> Stream.run()
  end
end
