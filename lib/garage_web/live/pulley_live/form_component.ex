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
          <.button phx-disable-with="Saving...">Save Pulley</.button>
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
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, pulley_params))}
  end

  def handle_event("save", %{"pulley" => pulley_params}, socket) do
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

  defp assign_form(%{assigns: %{pulley: pulley}} = socket) do
    form =
      if pulley do
        AshPhoenix.Form.for_update(pulley, :update,
          domain: Garage.Mopeds,
          as: "pulley",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Pulley, :create,
          domain: Garage.Mopeds,
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
