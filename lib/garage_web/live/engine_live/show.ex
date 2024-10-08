defmodule GarageWeb.EngineLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @engine.manufacturer.name %> <%= @engine.name %>

      <:actions>
        <.link patch={~p"/engines/#{@engine}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit engine</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Name"><%= @engine.name %></:item>

      <:item title="Description"><%= @engine.description %></:item>

      <:item title="Transmission">
        <%= @engine.transmission |> humanize() %>
      </:item>

      <:item title="Drive">
        <%= for drive <- @engine.drive || [] do %>
          <.badge><%= drive |> humanize() %></.badge>
        <% end %>
      </:item>

      <:item title="Manufacturer">
        <.link navigate={~p"/manufacturers/#{@engine.manufacturer}"}>
          <%= @engine.manufacturer.name %>
        </.link>
      </:item>
    </.list>

    <.back navigate={~p"/engines"}>Back to engines</.back>

    <.modal
      :if={@live_action == :edit}
      id="engine-modal"
      show
      on_cancel={JS.patch(~p"/engines/#{@engine}")}
    >
      <.live_component
        module={GarageWeb.EngineLive.FormComponent}
        id={@engine.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        engine={@engine}
        patch={~p"/engines/#{@engine}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :engine,
       Ash.get!(Garage.Mopeds.Engine, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Engine"
  defp page_title(:edit), do: "Edit Engine"
end
