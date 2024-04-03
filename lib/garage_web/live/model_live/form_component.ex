defmodule GarageWeb.ModelLive.FormComponent do
  use GarageWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage model records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="model-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:manufacturer_id]} type="text" label="Manufacturer" />
        <.input field={@form[:stock_carburetor_id]} type="text" label="Stock carburetor" />
        <.input field={@form[:stock_clutch_id]} type="text" label="Stock clutch" />
        <.input field={@form[:stock_crank_id]} type="text" label="Stock crank" />
        <.input field={@form[:stock_cylinder_id]} type="text" label="Stock cylinder" />
        <.input field={@form[:stock_engine_id]} type="text" label="Stock engine" />
        <.input field={@form[:stock_exhaust_id]} type="text" label="Stock exhaust" />
        <.input field={@form[:stock_forks_id]} type="text" label="Stock forks" />
        <.input field={@form[:stock_ignition_id]} type="text" label="Stock ignition" />
        <.input field={@form[:stock_pulley_id]} type="text" label="Stock pulley" />
        <.input field={@form[:stock_variator_id]} type="text" label="Stock variator" />
        <.input field={@form[:stock_wheels_id]} type="text" label="Stock wheels" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Model</.button>
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
  def handle_event("validate", %{"model" => model_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, model_params))}
  end

  def handle_event("save", %{"model" => model_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: model_params) do
      {:ok, model} ->
        notify_parent({:saved, model})

        socket =
          socket
          |> put_flash(:info, "Model #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{model: model}} = socket) do
    form =
      if model do
        AshPhoenix.Form.for_update(model, :update,
          api: Garage.Mopeds,
          as: "model",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Model, :create,
          api: Garage.Mopeds,
          as: "model",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
