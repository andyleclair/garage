defmodule GarageWeb.CarburetorLive.FormComponent do
  alias Garage.Mopeds.Carburetor
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
        <.chip :for={size <- @carburetor.sizes} myself={@myself}><%= size %></.chip>
        <.live_select
          field={@form[:tunable_parts]}
          phx-target={@myself}
          mode={:tags}
          update_min_len={0}
          phx-focus="set-default"
          label="Tunable Parts"
          options={@tunable_parts}
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

    tunable_parts = tunable_parts()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:manufacturer_options, manufacturer_options)
     |> assign(:tunable_parts, tunable_parts)
     |> assign(:sizes, assigns.carburetor.sizes)
     |> assign_form()}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "carburetor_" <> field},
        socket
      ) do
    options =
      case field do
        "manufacturer" <> _ ->
          search_options(socket.assigns.manufacturer_options, text)

        "tunable_parts" <> _ ->
          search_options(socket.assigns.tunable_parts, text)
      end

    send_update(LiveSelect.Component, options: options, id: id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set-default", %{"id" => "carburetor_" <> field = id}, socket) do
    options =
      case field do
        "manufacturer" <> _ ->
          socket.assigns.manufacturer_options

        "tunable_parts" <> _ ->
          socket.assigns.tunable_parts
      end

    send_update(LiveSelect.Component, options: options, id: id)

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
          as: "carburetor",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Garage.Mopeds.Carburetor, :create,
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

  def tunable_parts() do
    for part <-
          Ash.Resource.Info.attribute(Carburetor, :tunable_parts).constraints[:items][:one_of],
        into: [],
        do: {part |> to_string() |> Recase.to_title(), part}
  end

  def chip(assigns) do
    ~H"""
    <span
      id="badge-dismiss-default"
      class="inline-flex items-center px-2 py-1 me-2 text-sm font-medium text-blue-800 bg-blue-100 rounded dark:bg-blue-900 dark:text-blue-300"
    >
      <%= render_slot(@inner_block) %>
      <button
        type="button"
        class="inline-flex items-center p-1 ms-2 text-sm text-blue-400 bg-transparent rounded-sm hover:bg-blue-200 hover:text-blue-900 dark:hover:bg-blue-800 dark:hover:text-blue-300"
        data-dismiss-target="#badge-dismiss-default"
        aria-label="Remove"
        phx-click="dismiss"
        phx-target={@myself}
        phx-value-to-remove={render_slot(@inner_block)}
      >
        <svg
          class="w-2 h-2"
          aria-hidden="true"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 14 14"
        >
          <path
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"
          />
        </svg>
        <span class="sr-only">Remove badge</span>
      </button>
    </span>
    """
  end
end
