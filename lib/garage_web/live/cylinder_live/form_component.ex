defmodule GarageWeb.CylinderLive.FormComponent do
  use GarageWeb, :live_component

  alias Garage.Mopeds.Manufacturer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage cylinder records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="cylinder-form"
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
            value={@cylinder.manufacturer.name}
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
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:displacement]} type="text" label="Displacement (cc)" />
        <.input field={@form[:bore]} type="text" label="Bore (mm)" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Cylinder</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    manufacturer_options = manufacturer_options()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:manufacturer_options, manufacturer_options)
     |> assign_form()}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "cylinder_" <> field},
        socket
      ) do
    options =
      case field do
        "manufacturer" <> _ ->
          search_options(socket.assigns.manufacturer_options, text)
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "cylinder_" <> field = id}, socket) do
    options =
      case field do
        "manufacturer" <> _ ->
          socket.assigns.manufacturer_options
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"cylinder" => cylinder_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, cylinder_params))}
  end

  def handle_event("save", %{"cylinder" => cylinder_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: cylinder_params) do
      {:ok, _cylinder} ->
        socket =
          socket
          |> put_flash(:info, "Cylinder #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(%{assigns: %{cylinder: cylinder}} = socket) do
    form =
      if cylinder do
        AshPhoenix.Form.for_update(cylinder, :update,
          as: "cylinder",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Cylinder, :create,
          as: "cylinder",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def manufacturer_options() do
    for manufacturer <- Manufacturer.by_category!(:cylinders),
        into: [],
        do: {manufacturer.name, manufacturer.id}
  end
end
