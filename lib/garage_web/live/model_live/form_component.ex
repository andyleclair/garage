defmodule GarageWeb.ModelLive.FormComponent do
  use GarageWeb, :live_component
  alias Garage.Mopeds.Carburetor
  alias Garage.Mopeds.Clutch
  alias Garage.Mopeds.Crank
  alias Garage.Mopeds.Cylinder
  alias Garage.Mopeds.Engine
  alias Garage.Mopeds.Exhaust
  alias Garage.Mopeds.Ignition
  alias Garage.Mopeds.Manufacturer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="model-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.live_select
          field={@form[:manufacturer_id]}
          phx-focus="set-default"
          options={@manufacturer_options}
          phx-target={@myself}
          label="Manufacturer"
        />
        <.live_select
          label="Stock Carburetor"
          debounce="250"
          phx-focus="set-default"
          field={@form[:stock_carburetor_id]}
          options={@carburetor_options}
          phx-target={@myself}
        />

        <.live_select
          label="Stock Clutch"
          debounce="250"
          phx-focus="set-default"
          field={@form[:stock_clutch_id]}
          options={@clutch_options}
          phx-target={@myself}
        />
        <.input field={@form[:stock_crank_id]} type="text" label="Stock crank" />
        <.input field={@form[:stock_cylinder_id]} type="text" label="Stock cylinder" />
        <.input field={@form[:stock_engine_id]} type="text" label="Stock engine" />
        <.input field={@form[:stock_exhaust_id]} type="text" label="Stock exhaust" />
        <.input field={@form[:stock_ignition_id]} type="text" label="Stock ignition" />
        <.input field={@form[:stock_pulley_id]} type="text" label="Stock pulley" />
        <.input field={@form[:stock_variator_id]} type="text" label="Stock variator" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Model</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    manufacturers = Manufacturer.by_category!(:mopeds)
    carburetors = Carburetor.read_all!()
    engines = Engine.read_all!()
    clutches = Clutch.read_all!()
    exhausts = Exhaust.read_all!()
    ignitions = Ignition.read_all!()
    cylinders = Cylinder.read_all!()
    crankshafts = Crank.read_all!()

    {:ok,
     socket
     |> assign(:manufacturer_options, to_options(manufacturers))
     |> assign(:carburetor_options, to_options(carburetors))
     |> assign(:engine_options, to_options(engines))
     |> assign(:clutch_options, to_options(clutches))
     |> assign(:cylinder_options, to_options(cylinders))
     |> assign(:exhaust_options, to_options(exhausts))
     |> assign(:ignition_options, to_options(ignitions))
     |> assign(:crank_options, to_options(crankshafts))}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "model_" <> field},
        socket
      ) do
    options =
      case field do
        "manufacturer" <> _ ->
          search_options(socket.assigns.manufacturer_options, text)

        "stock_carb" <> _ ->
          search_options(socket.assigns.carburetor_options, text)

        "stock_engine" <> _ ->
          search_options(socket.assigns.engine_options, text)

        "stock_clutch" <> _ ->
          search_options(socket.assigns.clutch_options, text)

        "stock_exhaust" <> _ ->
          search_options(socket.assigns.exhaust_options, text)

        "stock_cylinder" <> _ ->
          search_options(socket.assigns.cylinder_options, text)

        "stock_ignition" <> _ ->
          search_options(socket.assigns.ignition_options, text)

        "stock_crank" <> _ ->
          search_options(socket.assigns.crank_options, text)
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "model" <> field = id}, socket) do
    options =
      case field do
        "_manufacturer" <> _ ->
          socket.assigns.manufacturer_options

        "_model" <> _ ->
          socket.assigns.model_options

        "_stock_carburetor" <> _ ->
          socket.assigns.carburetor_options

        "_stock_engine" <> _ ->
          socket.assigns.engine_options

        "_stock_clutch" <> _ ->
          socket.assigns.clutch_options

        "_stock_exhaust" <> _ ->
          socket.assigns.exhaust_options

        "_stock_cylinder" <> _ ->
          socket.assigns.cylinder_options

        "_stock_ignition" <> _ ->
          socket.assigns.ignition_options

        "_stock_crank" <> _ ->
          socket.assigns.crank_options
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"model" => model_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, model_params))}
  end

  def handle_event("save", %{"model" => model_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: model_params) do
      {:ok, _model} ->
        socket =
          socket
          |> put_flash(:info, "Model #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(%{assigns: %{model: model}} = socket) do
    form =
      if model do
        AshPhoenix.Form.for_update(model, :update,
          as: "model",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Model, :create,
          as: "model",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
