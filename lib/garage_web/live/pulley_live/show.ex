defmodule GarageWeb.PulleyLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @pulley.name %>

      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/pulleys/#{@pulley}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit pulley</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.list>
      <:item title="Name"><%= @pulley.name %></:item>

      <:item title="Description"><%= @pulley.description %></:item>

      <:item title="Manufacturer"><%= @pulley.manufacturer.name %></:item>
    </.list>

    <.back navigate={~p"/pulleys"}>Back to pulleys</.back>

    <.modal
      :if={@live_action == :edit}
      id="pulley-modal"
      show
      on_cancel={JS.patch(~p"/pulleys/#{@pulley}")}
    >
      <.live_component
        module={GarageWeb.PulleyLive.FormComponent}
        id={@pulley.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        pulley={@pulley}
        patch={~p"/pulleys/#{@pulley}"}
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
       :pulley,
       Ash.get!(Garage.Mopeds.Pulley, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Pulley"
  defp page_title(:edit), do: "Edit Pulley"
end
