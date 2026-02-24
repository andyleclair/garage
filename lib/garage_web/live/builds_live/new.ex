defmodule GarageWeb.BuildsLive.New do
  use GarageWeb, :live_view

  alias AshPhoenix.Form
  alias Garage.Builds
  alias Garage.Builds.Build
  alias Garage.Imports.Garage, as: GarageImport
  alias Garage.Imports.PartsMatcher
  alias Garage.Mopeds.Manufacturer
  alias Garage.Mopeds.Model
  import GarageWeb.BuildsLive.Helpers

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        New Build
        <:subtitle>Tell the world about your moped!</:subtitle>
      </.header>

      <.simple_form for={@form} id="build-form" phx-change="validate" phx-submit="save">
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
            />
          </div>
          <div class="w-1/3">
            <%= if @model_options do %>
              <.live_select
                field={@form[:model_id]}
                phx-focus="set-default"
                options={@model_options}
                label="Model"
                debounce="250"
              />
            <% end %>
          </div>
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save Build</.button>
        </:actions>
      </.simple_form>
    </div>
    <div class="relative flex py-5 items-center my-16">
      <div class="flex-grow border-t border-gray-400"></div>
      <span class="flex-shrink mx-4 text-gray-400">or</span>
      <div class="flex-grow border-t border-gray-400"></div>
    </div>
    <div>
      <.header>
        Import From '77 Garage
        <:subtitle>Import a build from '77 Garage by pasting in the URL here</:subtitle>
      </.header>
      <.simple_form
        for={@import_form}
        id="import-form"
        phx-change="import-validate"
        phx-submit="import"
      >
        <.input
          field={@import_form[:url]}
          type="text"
          label="URL"
          placeholder="https://garage.1977mopeds.com/build/..."
        />

        <%= if @import_loading do %>
          <div class="flex items-center gap-2 text-gray-500">
            <svg
              class="animate-spin h-5 w-5"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
              </circle>
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              >
              </path>
            </svg>
            <span>Loading preview...</span>
          </div>
        <% end %>

        <%= if @import_error do %>
          <div class="rounded-md bg-red-50 p-4">
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
                <p class="text-sm font-medium text-red-800">{@import_error}</p>
              </div>
            </div>
          </div>
        <% end %>

        <%= if @import_preview do %>
          <.import_preview
            preview={@import_preview}
            matched_parts={@matched_parts}
            import_manufacturer_options={@import_manufacturer_options}
            import_model_options={@import_model_options}
            import_form={@import_form}
          />
        <% end %>

        <:actions>
          <.button
            phx-disable-with="Importing..."
            disabled={is_nil(@import_preview) or @import_loading}
          >
            Import Build
          </.button>
        </:actions>
      </.simple_form>
    </div>

    <.back navigate={~p"/builds"}>Back to builds</.back>
    """
  end

  attr :preview, :map, required: true
  attr :matched_parts, :map, required: true
  attr :import_manufacturer_options, :list, required: true
  attr :import_model_options, :list, default: nil
  attr :import_form, :any, required: true

  defp import_preview(assigns) do
    ~H"""
    <div class="border rounded-lg p-4 mt-4 bg-gray-50">
      <.input
        field={@import_form[:name]}
        type="text"
        label="Build Name"
      />

      <%= if @preview.description && @preview.description != "" do %>
        <h4 class="font-semibold text-sm my-2">Description</h4>
        <div class="text-sm text-gray-600 mb-4 trix-content">
          {raw(@preview.description)}
        </div>
      <% end %>
      
    <!-- Image thumbnails -->
      <%= if length(@preview.image_urls) > 0 do %>
        <div class="flex gap-2 my-4 overflow-x-auto pb-2">
          <%= for url <- @preview.image_urls do %>
            <img
              src={url}
              class="h-24 w-auto rounded shadow-sm flex-shrink-0"
              loading="lazy"
              alt="Build image"
            />
          <% end %>
        </div>
        <p class="text-xs text-gray-500 mb-4">
          {length(@preview.image_urls)} image(s) will be imported
        </p>
      <% end %>
      
    <!-- Manufacturer/Model selection (required) -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
        <div>
          <.input
            field={@import_form[:year]}
            type="select"
            label="Year"
            options={year_options()}
            value={@preview.year}
          />
        </div>
        <div>
          <.live_select
            field={@import_form[:manufacturer_id]}
            phx-focus="import-set-default"
            options={@import_manufacturer_options}
            label="Manufacturer *"
          />
        </div>
        <div>
          <%= if @import_model_options do %>
            <.live_select
              field={@import_form[:model_id]}
              phx-focus="import-set-default"
              options={@import_model_options}
              label="Model *"
              debounce="250"
            />
          <% else %>
            <label class="block text-sm font-semibold leading-6 text-zinc-800">
              Model *
            </label>
            <p class="text-sm text-gray-500 mt-2">Select a manufacturer first</p>
          <% end %>
        </div>
      </div>
      
    <!-- Parts preview -->
      <%= if map_size(@preview.parts) > 0 do %>
        <div class="mt-4 border-t pt-4">
          <h4 class="font-semibold text-sm mb-2">Parts Found:</h4>
          <ul class="text-sm space-y-1">
            <%= for {category, part} <- @preview.parts do %>
              <li class="flex items-center gap-2">
                <span class="font-medium text-gray-700 w-24">
                  {humanize_category(category)}:
                </span>
                <span class="text-gray-600">{format_part(part)}</span>
                <%= if PartsMatcher.matched?(@matched_parts, category) do %>
                  <span class="inline-flex items-center rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-800">
                    Matched
                  </span>
                <% else %>
                  <span class="inline-flex items-center rounded-full bg-yellow-100 px-2 py-0.5 text-xs font-medium text-yellow-800">
                    Will add to description
                  </span>
                <% end %>
              </li>
            <% end %>
          </ul>
        </div>
      <% end %>
    </div>
    """
  end

  defp format_part(%{name: name, main_jet: main, idle_jet: idle}) do
    jets =
      [main && "Main: #{main}", idle && "Idle: #{idle}"]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(", ")

    if jets != "", do: "#{name} (#{jets})", else: name
  end

  defp format_part(%{name: name}), do: name
  defp format_part(name) when is_binary(name), do: name
  defp format_part(_), do: "Unknown"

  defp humanize_category(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  @impl true
  def mount(_params, _session, socket) do
    form =
      Form.for_action(Build, :create,
        domain: Builds,
        actor: socket.assigns.current_user
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

    import_form =
      to_form(
        %{"url" => "", "name" => "", "manufacturer_id" => nil, "model_id" => nil, "year" => nil},
        as: "import_form"
      )

    {:ok,
     socket
     |> assign(:page_title, "New Build")
     |> assign(:build, %Build{image_urls: []})
     |> assign(:manufacturer_options, manufacturer_options)
     |> assign(:model_options, model_options)
     |> assign(:year_options, year_options)
     |> assign_form(form)
     |> assign(:import_form, import_form)
     |> assign(:import_preview, nil)
     |> assign(:import_error, nil)
     |> assign(:import_loading, false)
     |> assign(:matched_parts, %{})
     |> assign(:import_manufacturer_options, manufacturer_options)
     |> assign(:import_model_options, nil)}
  end

  def handle_event("live_select_change", %{"id" => id, "text" => text, "field" => field}, socket) do
    options =
      case field do
        "form_manufacturer_id" ->
          search_options(socket.assigns.manufacturer_options, text)

        "form_model_id" ->
          search_options(socket.assigns.model_options, text)

        "import_form_manufacturer_id" ->
          search_options(socket.assigns.import_manufacturer_options, text)

        "import_form_model_id" ->
          search_options(socket.assigns.import_model_options || [], text)

        _ ->
          []
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => id}, socket) do
    case id do
      "form_manufacturer_id" <> _ ->
        send_update(LiveSelect.Component, options: socket.assigns.manufacturer_options, id: id)

      "form_model_id" <> _ ->
        send_update(LiveSelect.Component, options: socket.assigns.model_options, id: id)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("import-set-default", %{"id" => id}, socket) do
    case id do
      "import_form_manufacturer_id" <> _ ->
        send_update(LiveSelect.Component,
          options: socket.assigns.import_manufacturer_options,
          id: id
        )

      "import_form_model_id" <> _ ->
        send_update(LiveSelect.Component,
          options: socket.assigns.import_model_options || [],
          id: id
        )
    end

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
  def handle_event("import-validate", params, socket) do
    # Form params may be nested under "import_form" key or at top level
    form_params = Map.get(params, "import_form", params)
    url = get_url_from_params(form_params)

    # Update model options if manufacturer changed
    socket =
      case Map.get(form_params, "manufacturer_id") do
        nil ->
          socket

        "" ->
          assign(socket, :import_model_options, nil)

        manufacturer_id ->
          assign(socket, :import_model_options, model_options_by_id(manufacturer_id))
      end

    # Only fetch preview if URL looks valid and has changed
    current_url =
      case socket.assigns.import_preview do
        nil -> nil
        preview -> Map.get(preview, :source_url)
      end

    socket =
      if url != "" and url != current_url and GarageImport.valid_url?(url) do
        # Start async fetch
        send(self(), {:fetch_preview, url})
        assign(socket, import_loading: true, import_error: nil)
      else
        socket
      end

    import_form = to_form(form_params, as: "import_form")
    {:noreply, assign(socket, :import_form, import_form)}
  end

  @impl true
  def handle_event(
        "save",
        %{"form" => params},
        socket
      ) do
    case Form.submit(socket.assigns.form, params: params) do
      {:ok, build} ->
        {:noreply,
         socket
         |> put_flash(:info, "Build created successfully")
         |> push_navigate(to: ~p"/builds/#{build.slug}/edit")}

      {:error, form} ->
        {:noreply, assign_form(socket, form)}
    end
  end

  @impl true
  def handle_event("import", params, socket) do
    preview = socket.assigns.import_preview
    user = socket.assigns.current_user
    matched_parts = socket.assigns.matched_parts

    # Form params may be nested under "import_form" key or at top level
    form_params = Map.get(params, "import_form", params)

    name = Map.get(form_params, "name") || (preview && preview.name)
    manufacturer_id = Map.get(form_params, "manufacturer_id")
    model_id = Map.get(form_params, "model_id")
    year = Map.get(form_params, "year") || (preview && preview.year)

    # Validate required fields
    cond do
      is_nil(preview) ->
        {:noreply, assign(socket, :import_error, "No build preview loaded")}

      is_nil(name) or name == "" ->
        {:noreply, assign(socket, :import_error, "Please enter a build name")}

      is_nil(manufacturer_id) or manufacturer_id == "" ->
        {:noreply, assign(socket, :import_error, "Please select a manufacturer")}

      is_nil(model_id) or model_id == "" ->
        {:noreply, assign(socket, :import_error, "Please select a model")}

      true ->
        # Build description with unmatched parts appended
        description = build_description(preview, matched_parts)

        year_int =
          case year do
            y when is_integer(y) -> y
            y when is_binary(y) -> String.to_integer(y)
            _ -> preview.year || DateTime.utc_now().year
          end

        case Build.create(
               %{
                 name: name,
                 description: description,
                 year: year_int,
                 manufacturer_id: manufacturer_id,
                 model_id: model_id
               },
               actor: user
             ) do
          {:ok, build} ->
            # Apply matched tunings
            apply_matched_parts(build, matched_parts, preview.parts, user)

            # Create placeholder images immediately so they show up right away
            # Then queue background job to download and re-upload to S3
            if length(preview.image_urls) > 0 do
              images =
                Garage.Workers.ImportImages.create_placeholder_images(
                  build.id,
                  preview.image_urls
                )

              # Queue job to process images (download from '77 Garage, upload to S3)
              if length(images) > 0 do
                %{
                  "build_id" => build.id,
                  "image_ids" => Enum.map(images, & &1.id),
                  "username" => user.username,
                  "build_name" => build.name
                }
                |> Garage.Workers.ImportImages.new()
                |> Oban.insert!()
              end
            end

            {:noreply,
             socket
             |> put_flash(
               :info,
               "Build imported! Images are being processed in the background."
             )
             |> push_navigate(to: ~p"/builds/#{build.slug}/edit")}

          {:error, error} ->
            {:noreply, assign(socket, :import_error, format_build_error(error))}
        end
    end
  end

  defp format_build_error(%Ash.Error.Invalid{errors: errors}) do
    errors
    |> Enum.map(&format_ash_error/1)
    |> Enum.join(", ")
  end

  defp format_build_error(error) do
    "Failed to create build: #{inspect(error)}"
  end

  defp format_ash_error(%Ash.Error.Changes.InvalidAttribute{field: field, message: message}) do
    field_name = field |> to_string() |> String.replace("_", " ") |> String.capitalize()

    case message do
      "has already been taken" ->
        "A build with this name already exists. Please choose a different name."

      msg ->
        "#{field_name} #{msg}"
    end
  end

  defp format_ash_error(%{message: message}) when is_binary(message) do
    message
  end

  defp format_ash_error(error) do
    "An error occurred: #{inspect(error)}"
  end

  # Helper for import-validate
  defp get_url_from_params(%{"url" => url}), do: String.trim(url)
  defp get_url_from_params(_), do: ""

  @impl true
  def handle_info({:fetch_preview, url}, socket) do
    case GarageImport.get_build(url) do
      {:ok, preview} ->
        # Add source URL to preview for tracking
        preview = Map.put(preview, :source_url, url)

        # Match parts against database, with moped context for better "stock" part matching
        parts_context = %{
          manufacturer_name: preview.manufacturer_name,
          model_name: preview.model_name
        }

        matched_parts = PartsMatcher.match_all(preview.parts, parts_context)

        # Try to auto-match manufacturer and model
        {matched_manufacturer_id, matched_model_id, model_options} =
          match_manufacturer_and_model(
            preview.manufacturer_name,
            preview.model_name,
            socket.assigns.import_manufacturer_options
          )

        # Update the import form with matched values
        import_form =
          to_form(
            %{
              "url" => url,
              "name" => preview.name,
              "manufacturer_id" => matched_manufacturer_id,
              "model_id" => matched_model_id,
              "year" => preview.year
            },
            as: "import_form"
          )

        {:noreply,
         socket
         |> assign(:import_preview, preview)
         |> assign(:import_loading, false)
         |> assign(:import_error, nil)
         |> assign(:matched_parts, matched_parts)
         |> assign(:import_form, import_form)
         |> assign(:import_model_options, model_options)}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:import_preview, nil)
         |> assign(:import_loading, false)
         |> assign(:import_error, GarageImport.format_error(reason))
         |> assign(:matched_parts, %{})}
    end
  end

  # Try to match the manufacturer and model from the preview to our database
  defp match_manufacturer_and_model(manufacturer_name, model_name, manufacturer_options) do
    # Try to find matching manufacturer
    matched_manufacturer =
      if manufacturer_name do
        manufacturer_name_lower = String.downcase(manufacturer_name)

        Enum.find(manufacturer_options, fn {name, _id} ->
          String.downcase(name) == manufacturer_name_lower
        end)
      end

    case matched_manufacturer do
      {_name, manufacturer_id} ->
        # Found manufacturer, now try to find model
        model_options = model_options_by_id(manufacturer_id)

        matched_model =
          if model_name do
            model_name_lower = String.downcase(model_name)

            # Try exact match first
            # Try partial match (model name contains search or vice versa)
            Enum.find(model_options, fn {name, _id} ->
              String.downcase(name) == model_name_lower
            end) ||
              Enum.find(model_options, fn {name, _id} ->
                name_lower = String.downcase(name)

                String.contains?(name_lower, model_name_lower) or
                  String.contains?(model_name_lower, name_lower)
              end)
          end

        case matched_model do
          {_name, model_id} -> {manufacturer_id, model_id, model_options}
          nil -> {manufacturer_id, nil, model_options}
        end

      nil ->
        {nil, nil, nil}
    end
  end

  defp build_description(preview, matched_parts) do
    base_description = preview.description || ""

    unmatched_text =
      PartsMatcher.format_unmatched_for_description(matched_parts, preview.parts)

    if unmatched_text do
      base_description <> unmatched_text
    else
      base_description
    end
  end

  defp apply_matched_parts(build, matched_parts, original_parts, actor) do
    # Build update params for matched tunings
    update_params =
      matched_parts
      |> Enum.filter(fn {_type, result} -> match?({:ok, _}, result) end)
      |> Enum.reduce(%{}, fn {type, {:ok, part}}, acc ->
        case type do
          :cylinder ->
            Map.put(acc, :cylinder_tuning, %{cylinder_id: part.id})

          :carburetor ->
            carb_data = Map.get(original_parts, :carburetor, %{})

            tuning =
              %{carburetor_id: part.id}
              |> maybe_add_carb_tuning(carb_data)

            Map.put(acc, :carb_tuning, tuning)

          :exhaust ->
            Map.put(acc, :exhaust_id, part.id)

          :ignition ->
            Map.put(acc, :ignition_tuning, %{ignition_id: part.id})

          :clutch ->
            Map.put(acc, :clutch_tuning, %{clutch_id: part.id})

          :crank ->
            Map.put(acc, :crank_id, part.id)

          :engine ->
            Map.put(acc, :engine_tuning, %{engine_id: part.id})

          _ ->
            acc
        end
      end)

    # Update the build with matched parts
    if map_size(update_params) > 0 do
      Build.update(build, update_params, actor: actor)
    end
  end

  defp maybe_add_carb_tuning(tuning, %{main_jet: main, idle_jet: idle})
       when not is_nil(main) or not is_nil(idle) do
    jets = %{}
    jets = if main, do: Map.put(jets, "main_jet", main), else: jets
    jets = if idle, do: Map.put(jets, "idle_jet", idle), else: jets
    Map.put(tuning, :tuning, jets)
  end

  defp maybe_add_carb_tuning(tuning, _), do: tuning

  def manufacturer_options() do
    for manufacturer <- Manufacturer.by_category!(:mopeds),
        into: [],
        do: {manufacturer.name, manufacturer.id}
  end

  def model_options_by_id(manufacturer_id) do
    for model <- Model.by_manufacturer_id!(manufacturer_id), into: [], do: {model.name, model.id}
  end
end
