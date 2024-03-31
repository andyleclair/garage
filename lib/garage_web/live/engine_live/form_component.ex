defmodule GarageWeb.EngineLive.FormComponent do
  use GarageWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage engine records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="engine-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input
          field={@form[:transmission]}
          type="select"
          label="Transmission"
          options={@transmissions}
        />
        <.input field={@form[:manufacturer_id]} type="text" label="Manufacturer" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Engine</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    transmissions = transmissions()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(transmissions: transmissions)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"engine" => engine_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, engine_params))}
  end

  def handle_event("save", %{"engine" => engine_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: engine_params) do
      {:ok, engine} ->
        notify_parent({:saved, engine})

        socket =
          socket
          |> put_flash(:info, "Engine #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{engine: engine}} = socket) do
    form =
      if engine do
        AshPhoenix.Form.for_update(engine, :update,
          api: Garage.Mopeds,
          as: "engine",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Engine, :create,
          api: Garage.Mopeds,
          as: "engine",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def transmissions() do
    for t <-
          Ash.Resource.Info.attribute(Garage.Mopeds.Engine, :transmission).constraints[:one_of],
        do: {t |> to_string |> Recase.to_title(), t}
  end
end
