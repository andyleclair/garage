defmodule GarageWeb.ModelLive.Show do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @model.manufacturer.name %> <%= @model.name %>

      <:actions>
        <.link patch={~p"/models/#{@model}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit model</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Name"><%= @model.name %></:item>

      <:item title="Description"><%= @model.description %></:item>

      <:item title="Manufacturer">
        <.link navigate={~p"/manufacturers/#{@model.manufacturer}"}>
          <%= @model.manufacturer.name %>
        </.link>
      </:item>

      <:item title="Stock carburetor"><%= @model.stock_carburetor_id %></:item>

      <:item title="Stock clutch"><%= @model.stock_clutch_id %></:item>

      <:item title="Stock crank"><%= @model.stock_crank_id %></:item>

      <:item title="Stock cylinder"><%= @model.stock_cylinder_id %></:item>

      <:item title="Stock engine"><%= @model.stock_engine_id %></:item>

      <:item title="Stock exhaust"><%= @model.stock_exhaust_id %></:item>

      <:item title="Stock forks"><%= @model.stock_forks_id %></:item>

      <:item title="Stock ignition"><%= @model.stock_ignition_id %></:item>

      <:item title="Stock pulley"><%= @model.stock_pulley_id %></:item>

      <:item title="Stock variator"><%= @model.stock_variator_id %></:item>

      <:item title="Stock wheels"><%= @model.stock_wheels_id %></:item>
    </.list>

    <.back navigate={~p"/models"}>Back to models</.back>

    <.modal
      :if={@live_action == :edit}
      id="model-modal"
      show
      on_cancel={JS.patch(~p"/models/#{@model}")}
    >
      <.live_component
        module={GarageWeb.ModelLive.FormComponent}
        id={@model.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        model={@model}
        patch={~p"/models/#{@model}"}
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
       :model,
       Ash.get!(Garage.Mopeds.Model, id,
         load: [:manufacturer],
         actor: socket.assigns.current_user
       )
     )}
  end

  defp page_title(:show), do: "Show Model"
  defp page_title(:edit), do: "Edit Model"
end
