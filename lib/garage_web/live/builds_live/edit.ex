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
      form = form(build, assigns.current_user)

      year_options = year_options()
      manufacturers = Manufacturer.by_category!(:mopeds)
      carburetors = Carburetor.read_all!()
      engines = Engine.read_all!()
      clutches = Clutch.read_all!()
      exhausts = Exhaust.read_all!()
      ignitions = Ignition.read_all!()

      # if we already have a manufacturer set, show the model dropdown
      models =
        if manufacturer_id = form_manufacturer_id(form) do
          Model.by_manufacturer_id!(manufacturer_id)
        else
          nil
        end

      images = build.image_urls |> Enum.map(fn url -> {random_id(), url} end)

      selected_carb =
        if selected_carb_id = form |> Form.value(:carb_tuning) |> Form.value(:carburetor_id) do
          Enum.find(carburetors, fn carb -> carb.id == selected_carb_id end)
        else
          nil
        end

      {:ok,
       socket
       |> assign(:title, "Edit Build")
       |> assign(:build, build)
       |> assign(:manufacturer_options, to_options(manufacturers, &manufacturer_formatter/1))
       |> assign(:images, images)
       |> assign(:uploaded_images, [])
       |> assign(:images_to_delete, [])
       |> assign(:selected_carburetor, selected_carb)
       # get special treatment
       |> assign(:models, models)
       # get special treatment
       |> assign(:carburetors, carburetors)
       |> assign(:model_options, to_options(models, &model_formatter/1))
       |> assign(:carburetor_options, to_options(carburetors, &carburetor_formatter/1))
       |> assign(:engine_options, to_options(engines, &engine_formatter/1))
       |> assign(:clutch_options, to_options(clutches, &clutch_formatter/1))
       |> assign(:exhaust_options, to_options(exhausts, &exhaust_formatter/1))
       |> assign(:ignition_options, to_options(ignitions, &ignition_formatter/1))
       |> assign(:year_options, year_options)
       |> assign_form(form)
       |> allow_upload(:image_urls,
         accept: ~w(.jpg .jpeg .webp .png),
         max_entries: 10,
         external: &presign_upload/2
       )}
    else
      Logger.error(
        "Unauthorized access by #{inspect(assigns.current_user)} trying to edit #{slug}"
      )

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

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "form_" <> field},
        socket
      ) do
    options =
      case field do
        "manufacturer" <> _ ->
          search_options(socket.assigns.manufacturer_options, text)

        "model" <> _ ->
          search_options(socket.assigns.model_options, text)

        "[carb_tuning]" <> _ ->
          search_options(socket.assigns.carburetor_options, text)

        "engine" <> _ ->
          search_options(socket.assigns.engine_options, text)

        "clutch" <> _ ->
          search_options(socket.assigns.clutch_options, text)

        "exhaust" <> _ ->
          search_options(socket.assigns.exhaust_options, text)

        "ignition" <> _ ->
          search_options(socket.assigns.ignition_options, text)
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "form" <> field = id}, socket) do
    options =
      case field do
        "_manufacturer" <> _ ->
          socket.assigns.manufacturer_options

        "_model" <> _ ->
          socket.assigns.model_options

        "[carb_tuning]" <> _ ->
          socket.assigns.carburetor_options

        "_engine" <> _ ->
          socket.assigns.engine_options

        "_clutch" <> _ ->
          socket.assigns.clutch_options

        "_exhaust" <> _ ->
          socket.assigns.exhaust_options

        "_ignition" <> _ ->
          socket.assigns.ignition_options
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)

    socket = maybe_assign_models(socket, form)

    socket = maybe_assign_selected_carb(socket, form)

    {:noreply, assign_form(socket, form)}
  end

  @impl true
  def handle_event(
        "save",
        %{"form" => form},
        %{
          assigns: %{images: [_ | _] = images, images_to_delete: images_to_delete}
        } = socket
      ) do
    uploaded_files = socket.assigns.uploaded_images

    async_delete_images(images_to_delete)

    image_urls = for {_ref, img} <- images, do: img

    image_urls = (image_urls -- images_to_delete) ++ uploaded_files
    form = Map.put(form, "image_urls", image_urls)

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

  def manufacturer_formatter(manufacturer) do
    manufacturer.name
  end

  def model_formatter(model) do
    model.name
  end

  def carburetor_formatter(carburetor) do
    "#{carburetor.manufacturer.name} #{carburetor.name}"
  end

  def engine_formatter(engine) do
    "#{engine.manufacturer.name} #{engine.name}"
  end

  def clutch_formatter(clutch) do
    "#{clutch.manufacturer.name} #{clutch.name}"
  end

  def exhaust_formatter(exhaust) do
    "#{exhaust.manufacturer.name} #{exhaust.name}"
  end

  def ignition_formatter(ignition) do
    "#{ignition.manufacturer.name} #{ignition.name}"
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
    for img <- images_to_delete do
      Task.Supervisor.start_child(Garage.TaskSupervisor, fn ->
        with %URI{path: path} <- URI.parse(img) do
          bucket()
          |> S3.delete_object(path)
          |> ExAws.request!()
        end
      end)
    end
  end

  defp form(build, current_user) do
    form = Form.for_update(build, :update, forms: [auto?: true], actor: current_user)

    if Form.value(form, :carb_tuning) do
      form
    else
      Form.add_form(form, [:carb_tuning])
    end
  end

  defp maybe_assign_models(%{assigns: %{models: models}} = socket, form) do
    if manufacturer_id = form_manufacturer_id(form) do
      if is_list(models) and List.first(models).manufacturer_id == manufacturer_id do
        socket
      else
        models = Model.by_manufacturer_id!(manufacturer_id)

        assign(
          socket,
          :model_options,
          to_options(models, &model_formatter/1)
        )
      end
    else
      socket
    end
  end

  defp maybe_assign_models(socket, _form), do: socket

  defp maybe_assign_selected_carb(
         %{assigns: %{selected_carburetor: selected_carburetor, carburetors: carburetors}} =
           socket,
         form
       ) do
    if selected_carb_id = form |> Form.value(:carb_tuning) |> Form.value(:carburetor_id) do
      if is_struct(selected_carburetor, Carburetor) and selected_carburetor.id == selected_carb_id do
        socket
      else
        carb = Enum.find(carburetors, fn carb -> carb.id == selected_carb_id end)
        assign(socket, :selected_carburetor, carb)
      end
    else
      socket
    end
  end
end
