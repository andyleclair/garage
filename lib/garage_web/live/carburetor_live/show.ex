defmodule GarageWeb.CarburetorLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @carburetor.manufacturer.name %> <%= @carburetor.name %>

      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/carburetors/#{@carburetor}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit carburetor</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.list>
      <:item title="Manufacturer">
        <.link navigate={~p"/manufacturers/#{@carburetor.manufacturer}"}>
          <%= @carburetor.manufacturer.name %>
        </.link>
      </:item>

      <:item title="Name"><%= @carburetor.name %></:item>

      <:item title="Description"><%= @carburetor.description %></:item>

      <:item title="Sizes">
        <.badge :for={size <- @carburetor.sizes}><%= size %></.badge>
      </:item>

      <:item title="Tunable Parts">
        <.badge :for={part <- @carburetor.tunable_parts}>
          <%= part |> humanize() %>
        </.badge>
      </:item>
    </.list>

    <.back navigate={~p"/carburetors"}>Back to carburetors</.back>

    <.modal
      :if={@live_action == :edit}
      id="carburetor-modal"
      show
      on_cancel={JS.patch(~p"/carburetors/#{@carburetor}")}
    >
      <.live_component
        module={GarageWeb.CarburetorLive.FormComponent}
        id={@carburetor.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        carburetor={@carburetor}
        patch={~p"/carburetors/#{@carburetor}"}
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
       :carburetor,
       Ash.get!(Garage.Mopeds.Carburetor, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Carburetor"
  defp page_title(:edit), do: "Edit Carburetor"
end
