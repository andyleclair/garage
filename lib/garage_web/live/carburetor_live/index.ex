defmodule GarageWeb.CarburetorLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      All Carburetors
      <:actions>
        <.link patch={~p"/carburetors/new"}>
          <.button>New Carburetor</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="carburetors"
      rows={@streams.carburetors}
      row_click={fn {_id, carburetor} -> JS.navigate(~p"/carburetors/#{carburetor}") end}
    >
      <:col :let={{_id, carburetor}} label="Manufacturer">
        <.link navigate={~p"/manufacturers/#{carburetor.manufacturer}"}>
          <%= carburetor.manufacturer.name %>
        </.link>
      </:col>
      <:col :let={{_id, carburetor}} label="Name"><%= carburetor.name %></:col>

      <:col :let={{_id, carburetor}} label="Description"><%= carburetor.description %></:col>

      <:col :let={{_id, carburetor}} label="Sizes">
        <.badge :for={size <- carburetor.sizes}><%= size %></.badge>
      </:col>

      <:col :let={{_id, carburetor}} label="Tunable Parts">
        <.badge :for={part <- carburetor.tunable_parts}>
          <%= part |> to_string() |> Recase.to_title() %>
        </.badge>
      </:col>

      <:action :let={{_id, carburetor}}>
        <div class="sr-only">
          <.link navigate={~p"/carburetors/#{carburetor}"}>Show</.link>
        </div>

        <.link patch={~p"/carburetors/#{carburetor}/edit"}>Edit</.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="carburetor-modal"
      show
      on_cancel={JS.patch(~p"/carburetors")}
    >
      <.live_component
        module={GarageWeb.CarburetorLive.FormComponent}
        id={(@carburetor && @carburetor.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        carburetor={@carburetor}
        patch={~p"/carburetors"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :carburetors,
       Garage.Mopeds.read!(Garage.Mopeds.Carburetor, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Carburetor")
    |> assign(
      :carburetor,
      Garage.Mopeds.get!(Garage.Mopeds.Carburetor, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Carburetor")
    |> assign(:carburetor, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Carburetors")
    |> assign(:carburetor, nil)
  end

  @impl true
  def handle_info({GarageWeb.CarburetorLive.FormComponent, {:saved, carburetor}}, socket) do
    carburetor =
      Garage.Mopeds.get!(Garage.Mopeds.Carburetor, carburetor.id,
        actor: socket.assigns.current_user
      )

    {:noreply, stream_insert(socket, :carburetors, carburetor)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    carburetor =
      Garage.Mopeds.get!(Garage.Mopeds.Carburetor, id, actor: socket.assigns.current_user)

    Garage.Mopeds.destroy!(carburetor, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :carburetors, carburetor)}
  end
end
