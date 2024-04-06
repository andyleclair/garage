defmodule GarageWeb.ClutchLive.FormComponent do
  use GarageWeb, :live_component
  alias Garage.Mopeds.Manufacturer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage clutch records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="clutch-form"
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
          <.button phx-disable-with="Saving...">Save Clutch</.button>
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
        %{"id" => id, "text" => text, "field" => "clutch_" <> field},
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
  def handle_event("set-default", %{"id" => "clutch_" <> field = id}, socket) do
    options =
      case field do
        "manufacturer" <> _ ->
          socket.assigns.manufacturer_options
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"clutch" => clutch_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, clutch_params))}
  end

  def handle_event("save", %{"clutch" => clutch_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: clutch_params) do
      {:ok, _clutch} ->
        socket =
          socket
          |> put_flash(:info, "Clutch #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(%{assigns: %{clutch: clutch}} = socket) do
    form =
      if clutch do
        AshPhoenix.Form.for_update(clutch, :update,
          domain: Garage.Mopeds,
          as: "clutch",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Clutch, :create,
          domain: Garage.Mopeds,
          as: "clutch",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def manufacturer_options() do
    for manufacturer <- Manufacturer.by_category!(:clutches),
        into: [],
        do: {manufacturer.name, manufacturer.id}
  end
end
