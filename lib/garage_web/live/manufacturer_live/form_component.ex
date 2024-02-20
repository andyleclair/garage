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
        <.input field={@form[:name]} type="text" label="Name" />
        <.live_select
          field={@form[:category]}
          phx-target={@myself}
          label="Category"
          update_min_len={0}
          phx-focus="set-default"
          mode={:tags}
          options={@manufacturer_options}
        />
        <.input field={@form[:description]} type="text" label="Description" />

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
     |> assign(
       :manufacturer_options,
       Ash.Resource.Info.attribute(Garage.Mopeds.Manufacturer, :category).constraints[:one_of]
     )
     |> assign_form()}
  end

  @impl true
  def handle_event("set-default", %{"id" => id}, socket) do
    send_update(LiveSelect.Component, options: socket.assigns.manufacturer_options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("live_select_change", %{"id" => id, "text" => text}, socket) do
    options = search_options(socket.assigns.manufacturer_options, text)
    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
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
