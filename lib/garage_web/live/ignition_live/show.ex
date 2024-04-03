defmodule GarageWeb.IgnitionLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Ignition <%= @ignition.id %>
      <:subtitle>This is a ignition record from your database.</:subtitle>

      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/ignitions/#{@ignition}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit ignition</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.list>
      <:item title="Name"><%= @ignition.name %></:item>

      <:item title="Description"><%= @ignition.description %></:item>

      <:item title="Manufacturer"><%= @ignition.manufacturer.name %></:item>
    </.list>

    <.back navigate={~p"/ignitions"}>Back to ignitions</.back>

    <.modal
      :if={@live_action == :edit}
      id="ignition-modal"
      show
      on_cancel={JS.patch(~p"/ignitions/#{@ignition}")}
    >
      <.live_component
        module={GarageWeb.IgnitionLive.FormComponent}
        id={@ignition.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        ignition={@ignition}
        patch={~p"/ignitions/#{@ignition}"}
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
       :ignition,
       Garage.Mopeds.get!(Garage.Mopeds.Ignition, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Ignition"
  defp page_title(:edit), do: "Edit Ignition"
end
