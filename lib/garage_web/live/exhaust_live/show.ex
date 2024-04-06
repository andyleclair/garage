defmodule GarageWeb.ExhaustLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Exhaust <%= @exhaust.id %>
      <:subtitle>This is a exhaust record from your database.</:subtitle>

      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/exhausts/#{@exhaust}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit exhaust</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.list>
      <:item title="Name"><%= @exhaust.name %></:item>

      <:item title="Description"><%= @exhaust.description %></:item>

      <:item title="Manufacturer"><%= @exhaust.manufacturer.name %></:item>
    </.list>

    <.back navigate={~p"/exhausts"}>Back to exhausts</.back>

    <.modal
      :if={@live_action == :edit}
      id="exhaust-modal"
      show
      on_cancel={JS.patch(~p"/exhausts/#{@exhaust}")}
    >
      <.live_component
        module={GarageWeb.ExhaustLive.FormComponent}
        id={@exhaust.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        exhaust={@exhaust}
        patch={~p"/exhausts/#{@exhaust}"}
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
       :exhaust,
       Ash.get!(Garage.Mopeds.Exhaust, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Exhaust"
  defp page_title(:edit), do: "Edit Exhaust"
end
