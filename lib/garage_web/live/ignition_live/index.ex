defmodule GarageWeb.IgnitionLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      All Ignitions
      <:actions>
        <.link patch={~p"/ignitions/new"}>
          <.button>New Ignition</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="ignitions"
      rows={@streams.ignitions}
      row_click={fn {_id, ignition} -> JS.navigate(~p"/ignitions/#{ignition}") end}
    >
      <:col :let={{_id, ignition}} label="Manufacturer"><%= ignition.manufacturer.name %></:col>

      <:col :let={{_id, ignition}} label="Name"><%= ignition.name %></:col>

      <:col :let={{_id, ignition}} label="Description"><%= ignition.description %></:col>

      <:action :let={{_id, ignition}}>
        <%= if @current_user do %>
          <.link patch={~p"/ignitions/#{ignition}/edit"}>Edit</.link>
        <% end %>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="ignition-modal"
      show
      on_cancel={JS.patch(~p"/ignitions")}
    >
      <.live_component
        module={GarageWeb.IgnitionLive.FormComponent}
        id={(@ignition && @ignition.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        ignition={@ignition}
        patch={~p"/ignitions"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :ignitions,
       Ash.read!(Garage.Mopeds.Ignition, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ignition")
    |> assign(
      :ignition,
      Ash.get!(Garage.Mopeds.Ignition, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ignition")
    |> assign(:ignition, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "All Ignitions")
    |> assign(:ignition, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ignition = Ash.get!(Garage.Mopeds.Ignition, id, actor: socket.assigns.current_user)
    Ash.destroy!(ignition, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :ignitions, ignition)}
  end
end
