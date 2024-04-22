defmodule GarageWeb.VariatorLive.FormComponent do
  use GarageWeb, :live_component
  alias Garage.Mopeds.Manufacturer
  alias Garage.Mopeds.Variator

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage variator records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="variator-form"
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
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:size]} type="number" label="Size (mm)" />
        <.input field={@form[:type]} type="select" label="Type" options={@types} />
        <%= if AshPhoenix.Form.value(@form, :type) == :rollers do %>
          <div class="grid grid-rows-2 mb-6 auto-rows-max">
            <.input
              field={@form[:rollers]}
              type="range"
              min={Ash.Resource.Info.attribute(Variator, :rollers).constraints[:min]}
              max={Ash.Resource.Info.attribute(Variator, :rollers).constraints[:max]}
              label="Number of Rollers"
            />
            <div class="flex flex-row flex-none justify-between items-center">
              <span class="text-sm text-gray-500 dark:text-gray-400 ">
                3
              </span>
              <span class="text-sm text-gray-500 dark:text-gray-400 ">
                4
              </span>
              <span class="text-sm text-gray-500 dark:text-gray-400 ">
                5
              </span>
              <span class="text-sm text-gray-500 dark:text-gray-400 ">
                6
              </span>
              <span class="text-sm text-gray-500 dark:text-gray-400 ">
                7
              </span>
              <span class="text-sm text-gray-500 dark:text-gray-400 ">
                8
              </span>
            </div>
          </div>
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Variator</.button>
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
     |> assign(:types, types())
     |> assign_form()}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "variator_" <> field},
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
  def handle_event("set-default", %{"id" => "variator_" <> field = id}, socket) do
    options =
      case field do
        "manufacturer" <> _ ->
          socket.assigns.manufacturer_options
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"variator" => variator_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, variator_params))}
  end

  def handle_event("save", %{"variator" => variator_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: variator_params) do
      {:ok, _variator} ->
        socket =
          socket
          |> put_flash(:info, "Variator #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(%{assigns: %{variator: variator}} = socket) do
    form =
      if variator do
        AshPhoenix.Form.for_update(variator, :update,
          as: "variator",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Variator, :create,
          as: "variator",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def manufacturer_options() do
    for manufacturer <- Manufacturer.by_category!(:variators),
        into: [],
        do: {manufacturer.name, manufacturer.id}
  end

  def types() do
    for t <-
          Ash.Resource.Info.attribute(Garage.Mopeds.Variator, :type).constraints[:one_of],
        do: {humanize(t), t}
  end
end
