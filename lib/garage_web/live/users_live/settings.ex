defmodule GarageWeb.UsersLive.Settings do
  alias Garage.Accounts.User
  alias Garage.Accounts
  alias AshPhoenix.Form

  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>Settings</.header>

    <.simple_form for={@form} id="settings-form" phx-change="validate" phx-submit="save">
      <.input field={@form[:username]} type="text" label="Username" />
      <.input field={@form[:email]} type="text" label="Email" />
      <.label>
        Push Notifications
        <span class="text-sm font-medium italic">
          - receive notifications when your builds are liked or commented on and for updates on builds you follow!
        </span>
      </.label>
      <.button id="allow_push_button" phx-hook="PushNotification">Enable Push Notifications</.button>
      <!-- color management -->
      <div class="h-20 flex flex-col">
        <.label>
          Color
          <span class="text-sm font-medium italic">
            - your name will appear in this color around the site
          </span>
        </.label>
        <div class="flex flex-row h-full mt-2 space-x-4">
          <div class="h-full w-full rounded-md" style={"background-color: #{@user.color}"} />
          <img
            src={~p"/images/dice.svg"}
            title="roll the dice"
            class="h-16 cursor-pointer"
            phx-click={JS.push("new-color") |> JS.transition("strong-tilt-move-shake", time: 300)}
            phx-throttle="1000"
          />
        </div>
      </div>
      <!-- Avatar management -->
      <div class="md:flex justify-around space-x-4">
        <div class="md:w-1/2 sm:w-full">
          <h2 class="text-base font-semibold leading-7 text-gray-900">
            Current Avatar
          </h2>
          <img src={@user.avatar_url} title={"#{@user.name}'s avatar"} />
        </div>

        <div class="md:w-1/2 sm:w-full">
          <!-- Selected files preview section -->
          <%= if @uploads.avatar_url.entries != [] do %>
            <div class="">
              <h2 class="text-base font-semibold leading-7 text-gray-900">
                New Avatar
              </h2>

              <div class="">
                <%= for entry <- @uploads.avatar_url.entries do %>
                  <!-- Entry information -->
                  <div
                    class="pending-upload-item relative flex justify-between gap-x-6 py-5"
                    id={"entry-#{entry.ref}"}
                  >
                    <div class="">
                      <.live_img_preview entry={entry} class="h-full w-full flex-none bg-gray-50" />
                      <div class="min-w-0 flex-auto">
                        <p class="text-sm font-semibold leading-6 break-all text-gray-900">
                          <span class="absolute inset-x-0 -top-px bottom-0"></span> <%= entry.client_name %>
                        </p>
                      </div>
                    </div>
                  </div>
                  <progress value={entry.progress} max="100" class="w-full h-1">
                    <%= entry.progress %>%
                  </progress>

                  <div
                    phx-click="cancel-upload"
                    phx-value-ref={entry.ref}
                    id={"close_pic-#{entry.ref}"}
                    class="phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3 text-sm font-semibold leading-6 text-white active:text-white/80 text-center cursor-pointer"
                  >
                    Cancel
                  </div>
                  <!-- Entry errors -->
                  <div>
                    <%= for err <- upload_errors(@uploads.avatar_url, entry) do %>
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
                <% end %>
              </div>
            </div>

            <.live_file_input upload={@uploads.avatar_url} class="hidden" />
          <% else %>
            <div class="space-y-12">
              <div class="border-gray-900/10 pb-12">
                <h2 class="text-base font-semibold leading-7 text-gray-900">
                  New Avatar
                </h2>

                <p class="mt-1 text-sm leading-6 text-gray-600">
                  A photo is worth a thousand words...
                </p>
                <div class="col-span-full">
                  <div
                    class="mt-2 flex justify-center rounded-lg border border-dashed border-gray-900/25 px-6 py-10"
                    phx-drop-target={@uploads.avatar_url.ref}
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
                              <.live_file_input upload={@uploads.avatar_url} class="hidden" /> Upload
                            </label>
                          </div>
                        </label>

                        <p class="pl-1">or drag and drop</p>
                      </div>

                      <p class="text-xs leading-5 text-gray-600">PNG, JPG, GIF up to 10MB</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>

      <.input field={@form[:profile]} type="hidden" label="Profile" id="trix-editor" />
      <div id="rich-text" phx-update="ignore">
        <trix-editor class="trix-content" input="trix-editor"></trix-editor>
      </div>

      <:actions>
        <.button phx-disable-with="Saving...">Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    form = Form.for_update(user, :update, domain: Accounts, actor: user)

    {:ok,
     socket
     |> allow_upload(:avatar_url,
       accept: ~w(.jpg .jpeg .webp .png .gif),
       max_entries: 1,
       external: &presign_upload/2
     )
     |> assign(:user, user)
     |> assign_form(form)}
  end

  @impl true
  def handle_event("new-color", _, socket) do
    {:ok, updated_user} = User.generate_new_color(socket.assigns.user)
    {:noreply, socket |> assign(:user, updated_user) |> assign(:current_user, updated_user)}
  end

  @impl true
  def handle_event("push-notification-enabled", _params, socket) do
    {:ok, updated_user} =
      Ash.Changeset.for_update(socket.assigns.user, :update, %{enabled_push_notifications: true})
      |> Ash.update()

    {:noreply, socket |> assign(:user, updated_user)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar_url, ref)}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = Form.validate(socket.assigns.form, params)
    {:noreply, assign_form(socket, form)}
  end

  @impl true
  def handle_event("save", %{"form" => form}, socket) do
    params =
      consume_uploaded_entries(socket, :avatar_url, fn upload, _entry ->
        {:ok, public_path(upload.key)}
      end)
      |> case do
        [] -> form
        [avatar_url] -> Map.put(form, :avatar_url, avatar_url)
      end

    case Form.submit(socket.assigns.form, params: params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_navigate(to: ~p"/#{user.username}")}

      {:error, form} ->
        {:noreply, assign_form(socket, form)}
    end
  end

  defp presign_upload(entry, socket) do
    config = ExAws.Config.new(:s3)
    key = upload_path(socket.assigns.current_user, entry)

    {:ok, url} =
      ExAws.S3.presigned_url(config, :put, bucket(), key,
        expires_in: 3600,
        query_params: [{"Content-Type", entry.client_type}]
      )

    socket = assign(socket, :avatar_url, public_path(key))

    {:ok, %{uploader: "S3", key: key, url: url}, socket}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:external_client_failure), do: "External client failure"

  defp bucket, do: Application.get_env(:garage, :upload_bucket)

  defp upload_path(user, %Phoenix.LiveView.UploadEntry{client_name: name}) do
    "/garage/users/#{user.username}/#{Ash.UUID.generate()}-#{name}"
  end

  defp public_path(upload_path) do
    "#{public_root()}#{upload_path}"
  end

  defp public_root, do: Application.get_env(:garage, :public_image_root)
end
