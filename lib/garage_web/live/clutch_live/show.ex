defmodule GarageWeb.ClutchLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Clutch <%= @clutch.id %>

      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/clutches/#{@clutch}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit clutch</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.list>
      <:item title="Manufacturer">
        <.link navigate={~p"/manufacturers/#{@clutch.manufacturer}"}>
          <%= @clutch.manufacturer.name %>
        </.link>
      </:item>

      <:item title="Name"><%= @clutch.name %></:item>

      <:item title="Description"><%= @clutch.description %></:item>
    </.list>

    <.back navigate={~p"/clutches"}>Back to clutches</.back>

    <.modal
      :if={@live_action == :edit}
      id="clutch-modal"
      show
      on_cancel={JS.patch(~p"/clutches/#{@clutch}")}
    >
      <.live_component
        module={GarageWeb.ClutchLive.FormComponent}
        id={@clutch.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        clutch={@clutch}
        patch={~p"/clutches/#{@clutch}"}
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
       :clutch,
       Ash.get!(Garage.Mopeds.Clutch, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Clutch"
  defp page_title(:edit), do: "Edit Clutch"
end
