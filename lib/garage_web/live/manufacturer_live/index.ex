defmodule GarageWeb.ManufacturerLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Manufacturers
      <:actions>
        <.link patch={~p"/manufacturers/new"}>
          <.button>New Manufacturer</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="manufacturers"
      rows={@streams.manufacturers}
      row_click={fn {_id, manufacturer} -> JS.navigate(~p"/manufacturers/#{manufacturer}") end}
    >
      <:col :let={{_id, manufacturer}} label="Name"><%= manufacturer.name %></:col>

      <:col :let={{_id, manufacturer}} label="Categories">
        <.badge :for={category <- manufacturer.categories}>
          <%= category %>
        </.badge>
      </:col>

      <:col :let={{_id, manufacturer}} label="Description"><%= manufacturer.description %></:col>

      <:col :let={{_id, manufacturer}} label="Slug"><%= manufacturer.slug %></:col>

      <:action :let={{_id, manufacturer}}>
        <div class="sr-only">
          <.link navigate={~p"/manufacturers/#{manufacturer}"}>Show</.link>
        </div>

        <.link patch={~p"/manufacturers/#{manufacturer}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, manufacturer}}>
        <.link
          phx-click={JS.push("delete", value: %{id: manufacturer.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="manufacturer-modal"
      show
      on_cancel={JS.patch(~p"/manufacturers")}
    >
      <.live_component
        module={GarageWeb.ManufacturerLive.FormComponent}
        id={(@manufacturer && @manufacturer.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        manufacturer={@manufacturer}
        patch={~p"/manufacturers"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :manufacturers,
       Garage.Mopeds.read!(Garage.Mopeds.Manufacturer, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Manufacturer")
    |> assign(
      :manufacturer,
      Garage.Mopeds.get!(Garage.Mopeds.Manufacturer, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Manufacturer")
    |> assign(:manufacturer, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Manufacturers")
    |> assign(:manufacturer, nil)
  end

  @impl true
  def handle_info({GarageWeb.ManufacturerLive.FormComponent, {:saved, manufacturer}}, socket) do
    {:noreply, stream_insert(socket, :manufacturers, manufacturer)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    manufacturer =
      Garage.Mopeds.get!(Garage.Mopeds.Manufacturer, id, actor: socket.assigns.current_user)

    Garage.Mopeds.destroy!(manufacturer, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :manufacturers, manufacturer)}
  end
end
