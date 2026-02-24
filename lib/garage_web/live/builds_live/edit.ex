defmodule GarageWeb.BuildsLive.Edit do
  require Logger
  alias Garage.Mopeds.Variator
  alias Garage.Mopeds.Pulley
  use GarageWeb, :live_view

  alias AshPhoenix.Form
  alias ExAws.S3
  alias Garage.Builds.Build
  alias Garage.Builds.Image
  alias Garage.Mopeds.Carburetor
  alias Garage.Mopeds.Clutch
  alias Garage.Mopeds.Crank
  alias Garage.Mopeds.Cylinder
  alias Garage.Mopeds.Engine
  alias Garage.Mopeds.Exhaust
  alias Garage.Mopeds.Ignition
  alias Garage.Mopeds.Manufacturer
  alias Garage.Mopeds.Model

  import GarageWeb.BuildsLive.Helpers
  require Logger

  @impl true
  def mount(%{"build" => slug}, _session, %{assigns: assigns} = socket) do
    build = Build.get_by_slug!(slug)

    if Build.can_update?(assigns.current_user, build) do
      # Subscribe to image updates for this build
      if connected?(socket) do
        Garage.Workers.ImportImages.subscribe(build.id)
      end

      form = form(build, assigns.current_user)

      year_options = year_options()
      manufacturers = Manufacturer.by_category!(:mopeds)
      carburetors = Carburetor.read_all!()
      engines = Engine.read_all!()
      clutches = Clutch.read_all!()
      exhausts = Exhaust.read_all!()
      ignitions = Ignition.read_all!()
      cylinders = Cylinder.read_all!()
      crankshafts = Crank.read_all!()
      pulleys = Pulley.read_all!()
      variators = Variator.read_all!()

      # if we already have a manufacturer set, show the model dropdown
      models =
        if manufacturer_id = form_manufacturer_id(form) do
          Model.by_manufacturer_id!(manufacturer_id)
        else
          nil
        end

      {:ok,
       socket
       |> assign(:page_title, "Edit Build - #{build.name}")
       |> assign(:build, build)
       |> assign_form(form)
       |> assign(:manufacturer_options, to_options(manufacturers))
       |> assign(:images, build.images)
       |> assign(:uploaded_images, [])
       |> assign(:images_to_delete, [])
       |> assign(:models, models)
       |> assign(:carburetors, carburetors)
       |> assign(:engines, engines)
       |> assign(:clutches, clutches)
       |> assign(:ignitions, ignitions)
       |> assign(:cylinders, cylinders)
       |> assign(:variators, variators)
       |> maybe_assign_selected(form, :carb_tuning)
       |> maybe_assign_selected(form, :clutch_tuning)
       |> maybe_assign_selected(form, :cylinder_tuning)
       |> maybe_assign_selected(form, :ignition_tuning)
       |> maybe_assign_selected(form, :variator_tuning)
       |> maybe_assign_selected(form, :engine_tuning)
       |> assign(:model_options, to_options(models))
       |> assign(:carburetor_options, to_options(carburetors))
       |> assign(:engine_options, to_options(engines))
       |> assign(:clutch_options, to_options(clutches))
       |> assign(:cylinder_options, to_options(cylinders))
       |> assign(:exhaust_options, to_options(exhausts))
       |> assign(:ignition_options, to_options(ignitions))
       |> assign(:crank_options, to_options(crankshafts))
       |> assign(:pulley_options, to_options(pulleys))
       |> assign(:variator_options, to_options(variators))
       |> assign(
         :drive_options,
         to_options(
           Ash.Resource.Info.attribute(Garage.Mopeds.Engine, :drive).constraints[:items][:one_of]
         )
       )
       |> assign(:year_options, year_options)
       |> allow_upload(:image_urls,
         accept: ~w(.jpg .jpeg .webp .png),
         max_entries: 10,
         external: &presign_upload/2,
         auto_upload: true,
         max_file_size: max_size()
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
  def handle_event("delete-image", %{"id" => id}, socket) do
    index = Enum.find_index(socket.assigns.images, fn img -> img.id == id end)
    {image, rest_images} = List.pop_at(socket.assigns.images, index)

    {:noreply,
     socket
     |> assign(:images, rest_images)
     |> assign(:images_to_delete, [image | socket.assigns.images_to_delete])}
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

        "carb_tuning" <> _ ->
          search_options(socket.assigns.carburetor_options, text)

        "engine" <> _ ->
          search_options(socket.assigns.engine_options, text)

        "clutch" <> _ ->
          search_options(socket.assigns.clutch_options, text)

        "exhaust" <> _ ->
          search_options(socket.assigns.exhaust_options, text)

        "cylinder" <> _ ->
          search_options(socket.assigns.cylinder_options, text)

        "ignition" <> _ ->
          search_options(socket.assigns.ignition_options, text)

        "crank" <> _ ->
          search_options(socket.assigns.crank_options, text)

        "pulley" <> _ ->
          search_options(socket.assigns.pulley_options, text)

        "variator" <> _ ->
          search_options(socket.assigns.variator_options, text)
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

        "[engine_tuning]_engine" <> _ ->
          socket.assigns.engine_options

        "[engine_tuning]_drive" <> _ ->
          socket.assigns.drive_options

        "[clutch_tuning]" <> _ ->
          socket.assigns.clutch_options

        "_exhaust" <> _ ->
          socket.assigns.exhaust_options

        "[cylinder_tuning]" <> _ ->
          socket.assigns.cylinder_options

        "[ignition_tuning]" <> _ ->
          socket.assigns.ignition_options

        "[variator_tuning]" <> _ ->
          socket.assigns.variator_options

        "_crank" <> _ ->
          socket.assigns.crank_options

        "_pulley" <> _ ->
          socket.assigns.pulley_options
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)

    socket =
      socket
      |> maybe_assign_models(form)
      |> maybe_assign_selected(form, :carb_tuning)
      |> maybe_assign_selected(form, :clutch_tuning)
      |> maybe_assign_selected(form, :cylinder_tuning)
      |> maybe_assign_selected(form, :ignition_tuning)
      |> maybe_assign_selected(form, :variator_tuning)
      |> maybe_assign_selected(form, :engine_tuning)

    {:noreply, assign_form(socket, form)}
  end

  @impl true
  def handle_event(
        "save",
        %{"form" => params},
        %{
          assigns: %{
            images: images,
            images_to_delete: images_to_delete,
            build: %Build{id: build_id}
          }
        } = socket
      ) do
    uploaded_files =
      consume_uploaded_entries(socket, :image_urls, fn upload, _entry ->
        {:ok, %{"original_url" => public_path(upload.key), "build_id" => build_id}}
      end)

    images = Enum.map(images, fn i -> Map.from_struct(i) end) ++ uploaded_files
    params = Map.put(params, "images", images)

    case Form.submit(socket.assigns.form, params: params) do
      {:ok, build} ->
        async_delete_images(images_to_delete)
        create_resize_jobs(build.images)

        {:noreply,
         socket
         |> put_flash(:info, "Build updated successfully")
         |> push_navigate(to: ~p"/builds/#{build.slug}")}

      {:error, form} ->
        async_delete_images(uploaded_files)
        {:noreply, assign_form(socket, form)}
    end
  end

  # Handle PubSub messages for image updates
  @impl true
  def handle_info({:image_updated, updated_image}, socket) do
    # Update the image in our list
    images =
      socket.assigns.images
      |> Enum.map(fn img ->
        if img.id == updated_image.id, do: updated_image, else: img
      end)

    {:noreply, assign(socket, :images, images)}
  end

  @impl true
  def handle_info({:import_complete, successful, failed}, socket) do
    message =
      if failed > 0 do
        "Image import complete: #{successful} succeeded, #{failed} failed"
      else
        "All #{successful} images imported successfully!"
      end

    {:noreply, put_flash(socket, :info, message)}
  end

  defp create_resize_jobs(images) do
    images
    |> Enum.map(fn %{id: image_id} = img ->
      if is_nil(img.optimized_url) do
        %{"image_id" => image_id}
        |> Garage.Workers.Resize.new()
        |> Oban.insert!()
      else
        # already resized
        :ok
      end
    end)
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

  defp async_delete_images(images_to_delete) do
    for %Image{original_url: img, thumbnail_url: thumb, optimized_url: optimized} <-
          images_to_delete do
      async_delete_image(img)
      async_delete_image(thumb)
      async_delete_image(optimized)
    end
  end

  defp async_delete_image(url) when is_nil(url) do
    :ok
  end

  defp async_delete_image(url) do
    Task.Supervisor.start_child(Garage.TaskSupervisor, fn ->
      with %URI{path: path} <- URI.parse(url) do
        bucket()
        |> S3.delete_object(path)
        |> ExAws.request!()
      end
    end)
  end

  defp form(build, current_user) do
    Form.for_update(build, :update, forms: [auto?: true], actor: current_user)
    |> Form.add_form([:images])
    |> maybe_add_form(:carb_tuning)
    |> maybe_add_form(:clutch_tuning)
    |> maybe_add_form(:cylinder_tuning)
    |> maybe_add_form(:ignition_tuning)
    |> maybe_add_form(:variator_tuning)
    |> maybe_add_form(:engine_tuning)
  end

  def maybe_add_form(form, key) do
    if Form.value(form, key) do
      form
    else
      Form.add_form(form, [key])
    end
  end

  defp maybe_assign_models(%{assigns: %{models: models}} = socket, form) do
    if manufacturer_id = form_manufacturer_id(form) do
      if is_list(models) and List.first(models).manufacturer_id == manufacturer_id do
        socket
      else
        models = Model.by_manufacturer_id!(manufacturer_id)

        assign(socket, :model_options, to_options(models))
      end
    else
      socket
    end
  end

  defp maybe_assign_models(socket, _form), do: socket

  defp maybe_assign_selected(socket, form, :carb_tuning) do
    maybe_assign(
      socket,
      form,
      :carb_tuning,
      :carburetor_id,
      Carburetor,
      :selected_carburetor,
      :carburetors
    )
  end

  defp maybe_assign_selected(socket, form, :ignition_tuning) do
    maybe_assign(
      socket,
      form,
      :ignition_tuning,
      :ignition_id,
      Ignition,
      :selected_ignition,
      :ignitions
    )
  end

  defp maybe_assign_selected(socket, form, :clutch_tuning) do
    maybe_assign(
      socket,
      form,
      :clutch_tuning,
      :clutch_id,
      Clutch,
      :selected_clutch,
      :clutches
    )
  end

  defp maybe_assign_selected(socket, form, :cylinder_tuning) do
    maybe_assign(
      socket,
      form,
      :cylinder_tuning,
      :cylinder_id,
      Cylinder,
      :selected_cylinder,
      :cylinders
    )
  end

  defp maybe_assign_selected(socket, form, :variator_tuning) do
    maybe_assign(
      socket,
      form,
      :variator_tuning,
      :variator_id,
      Variator,
      :selected_variator,
      :variators
    )
  end

  defp maybe_assign_selected(socket, form, :engine_tuning) do
    maybe_assign(
      socket,
      form,
      :engine_tuning,
      :engine_id,
      Engine,
      :selected_engine,
      :engines
    )
  end

  def maybe_assign(
        %{assigns: assigns} = socket,
        form,
        form_id,
        item_id,
        mod,
        selected_item,
        collection
      ) do
    if form && Form.value(form, form_id) do
      if selected_id = form |> Form.value(form_id) |> Form.value(item_id) do
        item = assigns[selected_item]

        if is_struct(item, mod) and item.id == selected_id do
          socket
        else
          item = Enum.find(assigns[collection], fn thing -> thing.id == selected_id end)
          assign(socket, selected_item, item)
        end
      else
        assign(socket, selected_item, nil)
      end
    else
      assign(socket, selected_item, nil)
    end
  end

  defp max_size() do
    Application.get_env(:garage, :max_upload_size)
  end
end
