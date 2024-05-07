defmodule GarageWeb.EngineLive.FormComponent do
  use GarageWeb, :live_component
  alias Garage.Mopeds.Manufacturer

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
        <!-- Manufacturer is not editable when editing -->
        <%= if @action == :edit do %>
          <.input
            name="manufacturer"
            label="Manufacturer"
            type="text"
            value={@engine.manufacturer.name}
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
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input
          field={@form[:transmission]}
          type="select"
          label="Transmission"
          options={
            to_options(
              Ash.Resource.Info.attribute(Garage.Mopeds.Engine, :transmission).constraints[:one_of]
            )
          }
        />
        <.live_select
          field={@form[:drive]}
          phx-target={@myself}
          mode={:tags}
          update_min_len={0}
          phx-focus="set-default"
          label="Drive"
          options={@drives}
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Engine</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    manufacturers = Manufacturer.by_category!(:engines)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(manufacturer_options: to_options(manufacturers))
     |> assign(
       drives:
         to_options(
           Ash.Resource.Info.attribute(Garage.Mopeds.Engine, :drive).constraints[:items][:one_of]
         )
     )
     |> assign_form()}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "engine_" <> field},
        socket
      ) do
    options =
      case field do
        "manufacturer" <> _ ->
          search_options(socket.assigns.manufacturer_options, text)

        "drive" <> _ ->
          search_options(socket.assigns.drives, text)
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "engine_" <> field = id}, socket) do
    options =
      case field do
        "manufacturer" <> _ ->
          socket.assigns.manufacturer_options

        "drive" <> _ ->
          socket.assigns.drives
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
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
          as: "engine",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Engine, :create,
          as: "engine",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
