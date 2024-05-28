defmodule GarageWeb.ManufacturerLive.FormComponent do
  use GarageWeb, :live_component
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
        id="manufacturer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.live_select
          field={@form[:categories]}
          phx-target={@myself}
          label="Categories"
          update_min_len={0}
          phx-focus="set-default"
          mode={:tags}
          options={@categories}
        />
        <.input field={@form[:description]} type="textarea" label="Description" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Manufacturer</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    categories =
      Ash.Resource.Info.attribute(Manufacturer, :categories).constraints[:items][:one_of]

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:categories, categories)
     |> assign_form()}
  end

  @impl true
  def handle_event("set-default", %{"id" => id}, socket) do
    send_update(LiveSelect.Component, options: socket.assigns.categories, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("live_select_change", %{"id" => id, "text" => text}, socket) do
    options = search_options(socket.assigns.categories, text)
    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"manufacturer" => manufacturer_params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, manufacturer_params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"manufacturer" => manufacturer_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: manufacturer_params) do
      {:ok, _manufacturer} ->
        socket =
          socket
          |> put_flash(:info, "Manufacturer #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(%{assigns: %{manufacturer: manufacturer}} = socket) do
    form =
      if manufacturer do
        AshPhoenix.Form.for_update(manufacturer, :update,
          as: "manufacturer",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Manufacturer, :create,
          as: "manufacturer",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
