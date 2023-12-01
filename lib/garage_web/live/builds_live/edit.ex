defmodule GarageWeb.BuildsLive.Edit do
  alias Garage.Builds.Build
  use GarageWeb, :live_view

  alias AshPhoenix.Form
  alias ExAws.S3
  alias Garage.Builds
  import GarageWeb.BuildsLive.Helpers

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @title %>
      <:subtitle>Tell the world about your moped!</:subtitle>
    </.header>

    <.simple_form
      for={@form}
      id="build-form"
      phx-target={@myself}
      phx-change="validate"
      phx-submit="save"
    >
      <.input field={@form[:name]} type="text" label="Name" />
      <div class="flex justify-around">
        <div class="w-1/6">
          <.input field={@form[:year]} type="select" label="Year" options={@year_options} />
        </div>
        <div class="w-1/3">
          <.live_select
            field={@form[:manufacturer_id]}
            phx-focus="set-default"
            options={@manufacturer_options}
            label="Make"
            phx-target={@myself}
          />
        </div>
        <div class="w-1/3">
          <%= if @model_options do %>
            <.live_select
              field={@form[:model_id]}
              phx-focus="set-default"
              options={@model_options}
              label="Model"
              phx-target={@myself}
              debounce="250"
            />
          <% end %>
        </div>
      </div>
      <.input field={@form[:description]} type="hidden" label="Description" id="trix-editor" />
      <div id="rich-text" phx-update="ignore">
        <trix-editor class="trix-content" input="trix-editor"></trix-editor>
      </div>
      <div class="space-y-12">
        <div class="border-gray-900/10 pb-12">
          <h2 class="text-base font-semibold leading-7 text-gray-900">
            Images
          </h2>

          <div
            class="md:grid md:grid-cols-4 md:gap-4"
            id="edit-gallery"
            phx-hook="Sortable"
            data-list_id={@build.id}
          >
            <div
              :for={{ref, image_url} <- @images}
              id={"image-#{ref}"}
              class="hover:cursor-grab active:cursor-grabbing relative drag-item:focus-within:ring-0 drag-item:focus-within:ring-offset-0 drag-ghost:bg-zinc-300 drag-ghost:border-0 drag-ghost:ring-0"
              data-id={"image-#{ref}"}
            >
              <div class="drag-ghost:opacity-0">
                <img src={image_url} class="object-cover mb-5 rounded-lg" />
                <div
                  class="absolute top-0 right-0 cursor-pointer z-10 hover:border hover:border-red-500 hover:rounded-lg"
                  phx-click="delete-image"
                  phx-target={@myself}
                  phx-value-ref={ref}
                  id={"delete_image-#{ref}"}
                >
                  <.icon name="hero-x-mark" class="bg-red-500 w-10 h-10" />
                </div>
              </div>
            </div>
            <!-- Selected files preview section -->
            <%= if @uploads.image_urls.entries != [] do %>
              <div
                :for={entry <- @uploads.image_urls.entries}
                id={"entry-#{entry.ref}"}
                class="relative"
                data-id={"entry-#{entry.ref}"}
              >
                <!-- Entry information -->
                <div
                  class="pending-upload-item relative flex justify-between gap-x-6 py-5"
                  id={"entry-#{entry.ref}"}
                >
                  <div class="flex gap-x-4">
                    <.live_img_preview entry={entry} class="object-cover mb-5 rounded-lg" />
                  </div>

                  <div
                    class="absolute top-0 right-0 cursor-pointer z-10 hover:border hover:border-red-500 hover:rounded-lg"
                    phx-click="cancel-upload"
                    phx-target={@myself}
                    phx-value-ref={entry.ref}
                    id={"close_pic-#{entry.ref}"}
                  >
                    <.icon name="hero-x-mark" class="bg-red-500 w-10 h-10" />
                  </div>
                  <progress value={entry.progress} max="100" class="w-full h-1">
                    <%= entry.progress %>%
                  </progress>
                </div>
                <!-- Entry errors -->
                <div>
                  <%= for err <- upload_errors(@uploads.image_urls, entry) do %>
                    <div class="rounded-md bg-red-50 p-4 mb-2">
                      <div class="flex">
                        <div class="flex-shrink-0">
                          <svg
                            class="h-5 w-5 text-red-400"
                            viewBox="0 0 20 20"
                            fill="currentColor"
                            aria-hidden="true"
                          >
                            <path
                              fill-rule="evenodd"
                              d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.28 7.22a.75.75 0 00-1.06 1.06L8.94 10l-1.72 1.72a.75.75 0 101.06 1.06L10 11.06l1.72 1.72a.75.75 0 101.06-1.06L11.06 10l1.72-1.72a.75.75 0 00-1.06-1.06L10 8.94 8.28 7.22z"
                              clip-rule="evenodd"
                            />
                          </svg>
                        </div>

                        <div class="ml-3">
                          <h3 class="text-sm font-medium text-red-800">
                            <%= error_to_string(err) %>
                          </h3>
                        </div>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>

          <div class="col-span-full">
            <div
              class="mt-2 flex justify-center rounded-lg border border-dashed border-gray-900/25 px-6 py-10"
              phx-drop-target={@uploads.image_urls.ref}
            >
              <div class="text-center">
                <svg
                  class="mx-auto h-12 w-12 text-gray-300"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                  aria-hidden="true"
                >
                  <path
                    fill-rule="evenodd"
                    d="M1.5 6a2.25 2.25 0 012.25-2.25h16.5A2.25 2.25 0 0122.5 6v12a2.25 2.25 0 01-2.25 2.25H3.75A2.25 2.25 0 011.5 18V6zM3 16.06V18c0 .414.336.75.75.75h16.5A.75.75 0 0021 18v-1.94l-2.69-2.689a1.5 1.5 0 00-2.12 0l-.88.879.97.97a.75.75 0 11-1.06 1.06l-5.16-5.159a1.5 1.5 0 00-2.12 0L3 16.061zm10.125-7.81a1.125 1.125 0 112.25 0 1.125 1.125 0 01-2.25 0z"
                    clip-rule="evenodd"
                  />
                </svg>

                <div class="mt-4 flex text-sm leading-6 text-gray-600">
                  <label
                    for="file-upload"
                    class="relative cursor-pointer rounded-md bg-white font-semibold text-indigo-600 focus-within:outline-none focus-within:ring-2 focus-within:ring-indigo-600 focus-within:ring-offset-2 hover:text-indigo-500"
                  >
                    <div>
                      <label class="cursor-pointer">
                        <.live_file_input upload={@uploads.image_urls} class="hidden" /> Upload
                      </label>
                    </div>
                  </label>

                  <p class="pl-1">or drag and drop</p>
                </div>

                <p class="text-xs leading-5 text-gray-600">PNG, JPG, GIF up to 10MB</p>
                <p class="text-xs leading-5 text-gray-600">
                  Up to <%= @uploads.image_urls.max_entries %> pictures allowed at a time
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <:actions>
        <.button phx-disable-with="Saving...">Save Build</.button>
      </:actions>
    </.simple_form>

    <.back navigate={~p"/builds/#{@build.slug}"}>Back to build</.back>
    """
  end

  @impl true
  def mount(%{"build" => slug}, _session, %{assigns: assigns} = socket) do
    build = Build.get_by_slug!(slug)

    if Build.can_update?(assigns.current_user, build) do
      form =
        Form.for_action(build, :update,
          api: Builds,
          actor: assigns.current_user
        )

      year_options = year_options()
      manufacturer_options = manufacturer_options()

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
       |> assign(:page_title, "Edit Build")
       |> assign(:build, build)
       |> assign(:manufacturer_options, manufacturer_options)
       |> assign(:images, images)
       |> assign(:images_to_delete, [])
       |> assign(:model_options, model_options)
       |> assign(:year_options, year_options)
       |> allow_upload(:image_urls, accept: ~w(.jpg .jpeg .webp .png), max_entries: 10)}
    else
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
        %{"id" => "form_manufacturer" <> _ = id, "text" => text},
        socket
      ) do
    options = search_options(socket.assigns.manufacturer_options, text)
    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => "form_model" <> _ = id, "text" => text},
        socket
      ) do
    options = search_options(socket.assigns.model_options, text)
    send_update(LiveSelect.Component, options: options, id: id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "form_manufacturer" <> _ = id}, socket) do
    send_update(LiveSelect.Component, options: socket.assigns.manufacturer_options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "form_model" <> _ = id}, socket) do
    send_update(LiveSelect.Component, options: socket.assigns.model_options, id: id)

    {:noreply, socket}
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
          assigns: %{images: images, action: action, images_to_delete: images_to_delete}
        } = socket
      ) do
    uploaded_files =
      consume_uploaded_entries(socket, :image_urls, fn %{path: path}, entry ->
        upload_path = upload_path(entry)

        {:ok, %{status_code: 200}} =
          path
          |> S3.Upload.stream_file()
          |> S3.upload(bucket(), upload_path,
            acl: :public_read,
            content_type: entry.client_type,
            content_disposition: "inline"
          )
          |> ExAws.request()

        public_path = public_path(upload_path)

        {:ok, public_path}
      end)

    Enum.each(images_to_delete, fn img ->
      with %URI{path: path} <- URI.parse(img) do
        bucket()
        |> S3.delete_object(path)
        |> ExAws.request!()
      end
    end)

    image_urls = for {_ref, img} <- images, do: img

    image_urls = (image_urls -- images_to_delete) ++ uploaded_files
    form = Map.put(form, :image_urls, image_urls)

    save_build(socket, action, form)
  end

  defp save_build(socket, :edit, params) do
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
end
