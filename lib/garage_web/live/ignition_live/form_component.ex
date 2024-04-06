defmodule GarageWeb.IgnitionLive.FormComponent do
  use GarageWeb, :live_component
  alias Garage.Mopeds.Manufacturer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage ignition records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="ignition-form"
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

        <:actions>
          <.button phx-disable-with="Saving...">Save Ignition</.button>
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
     |> assign_form()}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "ignition_" <> field},
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
  def handle_event("set-default", %{"id" => "ignition_" <> field = id}, socket) do
    options =
      case field do
        "manufacturer" <> _ ->
          socket.assigns.manufacturer_options
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"ignition" => ignition_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, ignition_params))}
  end

  def handle_event("save", %{"ignition" => ignition_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: ignition_params) do
      {:ok, _ignition} ->
        socket =
          socket
          |> put_flash(:info, "Ignition #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(%{assigns: %{ignition: ignition}} = socket) do
    form =
      if ignition do
        AshPhoenix.Form.for_update(ignition, :update,
          domain: Garage.Mopeds,
          as: "ignition",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Ignition, :create,
          domain: Garage.Mopeds,
          as: "ignition",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def manufacturer_options() do
    for manufacturer <- Manufacturer.by_category!(:ignitions),
        into: [],
        do: {manufacturer.name, manufacturer.id}
  end
end
