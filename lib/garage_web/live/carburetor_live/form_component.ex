defmodule GarageWeb.CarburetorLive.FormComponent do
  use GarageWeb, :live_component
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
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:size]} type="text" label="Size" />
        <.input
          field={@form[:jets]}
          type="select"
          multiple
          label="Jets"
          options={[{"Main", "main"}, {"Starter", "starter"}, {"Idle", "idle"}, {"Power", "power"}]}
        />
        <.live_select
          field={@form[:manufacturer_id]}
          phx-focus="set-default"
          options={@manufacturer_options}
          phx-target={@myself}
          label="Make"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Carburetor</.button>
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
  def handle_event("live_select_change", %{"id" => id, "text" => text}, socket) do
    options = search_options(socket.assigns.manufacturer_options, text)

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => id}, socket) do
    send_update(LiveSelect.Component, options: socket.assigns.manufacturer_options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"carburetor" => carburetor_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, carburetor_params))}
  end

  def handle_event("save", %{"carburetor" => carburetor_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: carburetor_params) do
      {:ok, carburetor} ->
        notify_parent({:saved, carburetor})

        socket =
          socket
          |> put_flash(:info, "Carburetor #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{carburetor: carburetor}} = socket) do
    form =
      if carburetor do
        AshPhoenix.Form.for_update(carburetor, :update,
          api: Garage.Mopeds,
          as: "carburetor",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Carburetor, :create,
          api: Garage.Mopeds,
          as: "carburetor",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def manufacturer_options() do
    for manufacturer <- Manufacturer.by_category!(:carburetor),
        into: [],
        do: {manufacturer.name, manufacturer.id}
  end
end
