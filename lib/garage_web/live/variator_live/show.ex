defmodule GarageWeb.VariatorLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Variator <%= @variator.id %>
      <:subtitle>This is a variator record from your database.</:subtitle>

      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/variators/#{@variator}/show/edit"} phx-click={JS.push_focus()}>
            <.button>Edit variator</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.list>
      <:item title="Name"><%= @variator.name %></:item>

      <:item title="Description"><%= @variator.description %></:item>

      <:item title="Manufacturer"><%= @variator.manufacturer.name %></:item>
    </.list>

    <.back navigate={~p"/variators"}>Back to variators</.back>

    <.modal
      :if={@live_action == :edit}
      id="variator-modal"
      show
      on_cancel={JS.patch(~p"/variators/#{@variator}")}
    >
      <.live_component
        module={GarageWeb.VariatorLive.FormComponent}
        id={@variator.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        variator={@variator}
        patch={~p"/variators/#{@variator}"}
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
       :variator,
       Ash.get!(Garage.Mopeds.Variator, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Variator"
  defp page_title(:edit), do: "Edit Variator"
end
