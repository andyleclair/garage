defmodule GarageWeb.CrankLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @crank.name %>

      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/cranks/#{@crank}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit crank</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.list>
      <:item title="Manufacturer">
        <.link navigate={~p"/manufacturers/#{@crank.manufacturer}"}>
          <%= @crank.manufacturer.name %>
        </.link>
      </:item>
      <:item title="Name"><%= @crank.name %></:item>

      <:item title="Engine">
        <%= if @crank.engine  do %>
          <.link navigate={~p"/engines/#{@crank.engine}"}>
            <%= @crank.engine.name %>
          </.link>
        <% end %>
      </:item>
      <:item title="Description"><%= @crank.description %></:item>

      <:item title="Stroke (mm)"><%= @crank.stroke %></:item>

      <:item title="Conn rod length (mm)"><%= @crank.conn_rod_length %></:item>

      <:item title="Small end bearing diameter (mm)">
        <%= @crank.small_end_bearing_diameter %>
      </:item>
    </.list>

    <.back navigate={~p"/cranks"}>Back to cranks</.back>

    <.modal
      :if={@live_action == :edit}
      id="crank-modal"
      show
      on_cancel={JS.patch(~p"/cranks/#{@crank}")}
    >
      <.live_component
        module={GarageWeb.CrankLive.FormComponent}
        id={@crank.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        crank={@crank}
        patch={~p"/cranks/#{@crank}"}
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
       :crank,
       Ash.get!(Garage.Mopeds.Crank, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Crank"
  defp page_title(:edit), do: "Edit Crank"
end
