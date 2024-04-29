defmodule GarageWeb.PulleyLive.FormComponent do
  use GarageWeb, :live_component
  alias Garage.Mopeds.Manufacturer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage pulley records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="pulley-form"
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
            value={@pulley.manufacturer.name}
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
        <.tag_selector
          id="size-select"
          label="Sizes"
          tags={@sizes}
          on_tag_update={fn sizes -> send_update(@myself, sizes: sizes) end}
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Pulley</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    manufacturer_options = manufacturer_options()

    {:ok,
     socket
     |> assign(:manufacturer_options, manufacturer_options)}
  end

  @impl true
  def update(assigns, socket) do
    sizes = if assigns[:sizes], do: assigns.sizes, else: []

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:sizes, sizes)
     |> assign_form()}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "pulley_" <> field},
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
  def handle_event("set-default", %{"id" => "pulley_" <> field = id}, socket) do
    options =
      case field do
        "manufacturer" <> _ ->
          socket.assigns.manufacturer_options
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"pulley" => pulley_params}, socket) do
    pulley_params = Map.put(pulley_params, "sizes", socket.assigns.sizes)
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, pulley_params))}
  end

  def handle_event("save", %{"pulley" => pulley_params}, socket) do
    pulley_params = Map.put(pulley_params, "sizes", socket.assigns.sizes)

    case AshPhoenix.Form.submit(socket.assigns.form, params: pulley_params) do
      {:ok, _pulley} ->
        socket =
          socket
          |> put_flash(:info, "Pulley #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(%{assigns: %{form: _form}} = socket) do
    socket
  end

  defp assign_form(%{assigns: %{pulley: pulley}} = socket) do
    form =
      if pulley do
        AshPhoenix.Form.for_update(pulley, :update,
          as: "pulley",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Pulley, :create,
          as: "pulley",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def manufacturer_options() do
    for manufacturer <- Manufacturer.by_category!(:pulleys),
        into: [],
        do: {manufacturer.name, manufacturer.id}
  end
end
