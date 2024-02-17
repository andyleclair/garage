defmodule GarageWeb.ManufacturerLive.FormComponent do
  use GarageWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage manufacturer records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="manufacturer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:id]} type="text" label="Id" /><.input
          field={@form[:name]}
          type="text"
          label="Name"
        /><.input
          field={@form[:category]}
          type="select"
          label="Category"
          options={
            Ash.Resource.Info.attribute(Garage.Mopeds.Manufacturer, :category).constraints[:one_of]
          }
        />
        <.input field={@form[:description]} type="text" label="Description" /><.input
          field={@form[:slug]}
          type="text"
          label="Slug"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Manufacturer</.button>
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
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"manufacturer" => manufacturer_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, manufacturer_params))}
  end

  def handle_event("save", %{"manufacturer" => manufacturer_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: manufacturer_params) do
      {:ok, manufacturer} ->
        notify_parent({:saved, manufacturer})

        socket =
          socket
          |> put_flash(:info, "Manufacturer #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{manufacturer: manufacturer}} = socket) do
    form =
      if manufacturer do
        AshPhoenix.Form.for_update(manufacturer, :update,
          api: Garage.Mopeds,
          as: "manufacturer",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Manufacturer, :create,
          api: Garage.Mopeds,
          as: "manufacturer",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
