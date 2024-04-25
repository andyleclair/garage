defmodule GarageWeb.CarburetorLive.FormComponent do
  use GarageWeb, :live_component

  alias Garage.Mopeds.Carburetor
  alias Garage.Mopeds.Manufacturer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage carburetor records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="carburetor-form"
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
            value={@carburetor.manufacturer.name}
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
          phx-target={@myself}
          on_tag_update={fn sizes -> send_update(@myself, sizes: sizes) end}
        />
        <.live_select
          field={@form[:tunable_parts]}
          phx-target={@myself}
          mode={:tags}
          update_min_len={0}
          phx-focus="set-default"
          label="Tunable Parts"
          options={@tunable_parts}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Carburetor</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    manufacturer_options = manufacturer_options()
    tunable_parts = tunable_parts()

    {:ok,
     socket
     |> assign(:manufacturer_options, manufacturer_options)
     |> assign(:tunable_parts, tunable_parts)}
  end

  @impl true
  def update(assigns, socket) do
    sizes = if assigns[:carburetor], do: assigns.carburetor.sizes, else: []
    sizes = if assigns[:sizes], do: assigns.sizes, else: sizes

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:sizes, sizes)
     |> assign_form()}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "carburetor_" <> field},
        socket
      ) do
    options =
      case field do
        "manufacturer" <> _ ->
          search_options(socket.assigns.manufacturer_options, text)

        "tunable_parts" <> _ ->
          search_options(socket.assigns.tunable_parts, text)
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "carburetor_" <> field = id}, socket) do
    options =
      case field do
        "manufacturer" <> _ ->
          socket.assigns.manufacturer_options

        "tunable_parts" <> _ ->
          socket.assigns.tunable_parts
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"carburetor" => carburetor_params}, socket) do
    carburetor_params = Map.put(carburetor_params, "sizes", socket.assigns.sizes)

    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, carburetor_params))}
  end

  def handle_event("save", %{"carburetor" => carburetor_params}, socket) do
    carburetor_params = Map.put(carburetor_params, "sizes", socket.assigns.sizes)

    case AshPhoenix.Form.submit(socket.assigns.form, params: carburetor_params) do
      {:ok, _carburetor} ->
        socket =
          socket
          |> put_flash(:info, "Carburetor #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(%{assigns: %{form: _form}} = socket) do
    socket
  end

  defp assign_form(%{assigns: %{carburetor: carburetor}} = socket) do
    form =
      if carburetor do
        AshPhoenix.Form.for_update(carburetor, :update,
          as: "carburetor",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Carburetor, :create,
          as: "carburetor",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def manufacturer_options() do
    for manufacturer <- Manufacturer.by_category!(:carburetors),
        into: [],
        do: {manufacturer.name, manufacturer.id}
  end

  def tunable_parts() do
    for part <-
          Ash.Resource.Info.attribute(Carburetor, :tunable_parts).constraints[:items][:one_of],
        into: [],
        do: {humanize(part), part}
  end
end
