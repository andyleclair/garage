defmodule GarageWeb.BuildsLive.New do
  use GarageWeb, :live_view

  alias AshPhoenix.Form
  alias Garage.Builds
  alias Garage.Builds.Build
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

    <.back navigate={~p"/builds"}>Back to builds</.back>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    form =
      Form.for_action(Build, :create,
        api: Builds,
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

    {:ok,
     socket
     |> assign(:page_title, "New Build")
     |> assign(:build, %Build{image_urls: []})
     |> assign(:manufacturer_options, manufacturer_options)
     |> assign(:model_options, model_options)
     |> assign(:year_options, year_options)
     |> assign_form(form)}
  end

  def handle_event("live_select_change", %{"id" => id, "text" => text, "field" => field}, socket) do
    options =
      case field do
        "form_manufacturer_id" -> search_options(socket.assigns.manufacturer_options, text)
        "form_model_id" -> search_options(socket.assigns.model_options, text)
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
end
