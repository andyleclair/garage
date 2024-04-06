defmodule GarageWeb.ManufacturerLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @manufacturer.name %>
      <:subtitle>This is a manufacturer record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/manufacturers/#{@manufacturer}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit manufacturer</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id"><%= @manufacturer.id %></:item>

      <:item title="Name"><%= @manufacturer.name %></:item>

      <:item title="Categories">
        <.badge :for={category <- @manufacturer.categories}>
          <%= category %>
        </.badge>
      </:item>

      <:item title="Description"><%= @manufacturer.description %></:item>

      <:item title="Slug"><%= @manufacturer.slug %></:item>
    </.list>

    <.back navigate={~p"/manufacturers"}>Back to manufacturers</.back>

    <.modal
      :if={@live_action == :edit}
      id="manufacturer-modal"
      show
      on_cancel={JS.patch(~p"/manufacturers/#{@manufacturer}")}
    >
      <.live_component
        module={GarageWeb.ManufacturerLive.FormComponent}
        id={@manufacturer.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        manufacturer={@manufacturer}
        patch={~p"/manufacturers/#{@manufacturer}"}
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
       :manufacturer,
       Ash.get!(Garage.Mopeds.Manufacturer,
         slug: id,
         actor: socket.assigns.current_user
       )
     )}
  end

  defp page_title(:show), do: "Show Manufacturer"
  defp page_title(:edit), do: "Edit Manufacturer"
end
