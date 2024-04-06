defmodule GarageWeb.CrankLive.FormComponent do
  use GarageWeb, :live_component
  alias Garage.Mopeds.Engine
  alias Garage.Mopeds.Manufacturer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage crank records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="crank-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <!-- Manufacturer is not editable when editing -->
        <%= if @action == :edit do %>
          <.input
            name="manufacturer"
            label="Manufacturer"
            type="text"
            value={@clutch.manufacturer.name}
            disabled
          />
        <% else %>
          <.live_select
            field={@form[:manufacturer_id]}
            phx-focus="set-default"
            options={@manufacturer_options}
            phx-target={@myself}
            label="Manufacturer"
          />
        <% end %>
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:stroke]} type="number" label="Stroke" />
        <.input field={@form[:conn_rod_length]} type="number" label="Conn rod length" />
        <.input
          field={@form[:small_end_bearing_diameter]}
          type="number"
          label="Small end bearing diameter"
        />
        <.live_select
          field={@form[:engine_id]}
          phx-focus="set-default"
          options={@engine_options}
          phx-target={@myself}
          label="Engine"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Crank</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:manufacturer_options, manufacturer_options())
     |> assign(:engine_options, engine_options())
     |> assign_form()}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "crank_" <> field},
        socket
      ) do
    options =
      case field do
        "manufacturer" <> _ ->
          search_options(socket.assigns.manufacturer_options, text)

        "engine" <> _ ->
          search_options(socket.assigns.engine_options, text)
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "crank_" <> field = id}, socket) do
    options =
      case field do
        "manufacturer" <> _ ->
          socket.assigns.manufacturer_options

        "engine" <> _ ->
          socket.assigns.engine_options
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"crank" => crank_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, crank_params))}
  end

  def handle_event("save", %{"crank" => crank_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: crank_params) do
      {:ok, _crank} ->
        socket =
          socket
          |> put_flash(:info, "Crank #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(%{assigns: %{crank: crank}} = socket) do
    form =
      if crank do
        AshPhoenix.Form.for_update(crank, :update,
          domain: Garage.Mopeds,
          as: "crank",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Crank, :create,
          domain: Garage.Mopeds,
          as: "crank",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def manufacturer_options() do
    for manufacturer <- Manufacturer.by_category!(:cranks),
        into: [],
        do: {manufacturer.name, manufacturer.id}
  end

  def engine_options() do
    for engine <- Engine.read_all!(load: [:manufacturer]),
        into: [],
        do: {"#{engine.manufacturer.name} #{engine.name}", engine.id}
  end
end
