defmodule GarageWeb.CylinderLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @cylinder.manufacturer.name %> <%= @cylinder.name %>

      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/cylinders/#{@cylinder}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit cylinder</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.list>
      <:item title="Manufacturer">
        <.link navigate={~p"/manufacturers/#{@cylinder.manufacturer}"}>
          <%= @cylinder.manufacturer.name %>
        </.link>
      </:item>

      <:item title="Name"><%= @cylinder.name %></:item>

      <:item title="Description"><%= @cylinder.description %></:item>

      <:item title="Displacement">
        <.badge :if={@cylinder.displacement}><%= @cylinder.displacement %> cc</.badge>
      </:item>
      <:item title="Bore">
        <.badge :if={@cylinder.bore}><%= @cylinder.bore %> mm</.badge>
      </:item>
    </.list>

    <.back navigate={~p"/cylinders"}>Back to cylinders</.back>

    <.modal
      :if={@live_action == :edit}
      id="cylinder-modal"
      show
      on_cancel={JS.patch(~p"/cylinders/#{@cylinder}")}
    >
      <.live_component
        module={GarageWeb.CylinderLive.FormComponent}
        id={@cylinder.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        cylinder={@cylinder}
        patch={~p"/cylinders/#{@cylinder}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, url, socket) do
    {:noreply,
     socket
     |> assign(:meta, %{"og:url" => url})
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :cylinder,
       Ash.get!(Garage.Mopeds.Cylinder, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Cylinder"
  defp page_title(:edit), do: "Edit Cylinder"
end
