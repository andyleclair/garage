defmodule GarageWeb.ExhaustLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Exhausts
      <:actions>
        <.link patch={~p"/exhausts/new"}>
          <.button>New Exhaust</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="exhausts"
      rows={@streams.exhausts}
      row_click={fn {_id, exhaust} -> JS.navigate(~p"/exhausts/#{exhaust}") end}
    >
      <:col :let={{_id, exhaust}} label="Manufacturer"><%= exhaust.manufacturer.name %></:col>

      <:col :let={{_id, exhaust}} label="Name"><%= exhaust.name %></:col>

      <:col :let={{_id, exhaust}} label="Description"><%= exhaust.description %></:col>

      <:action :let={{_id, exhaust}}>
        <%= if @current_user do %>
          <.link patch={~p"/exhausts/#{exhaust}/edit"}>Edit</.link>
        <% end %>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="exhaust-modal"
      show
      on_cancel={JS.patch(~p"/exhausts")}
    >
      <.live_component
        module={GarageWeb.ExhaustLive.FormComponent}
        id={(@exhaust && @exhaust.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        exhaust={@exhaust}
        patch={~p"/exhausts"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :exhausts,
       Garage.Mopeds.read!(Garage.Mopeds.Exhaust, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Exhaust")
    |> assign(
      :exhaust,
      Garage.Mopeds.get!(Garage.Mopeds.Exhaust, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Exhaust")
    |> assign(:exhaust, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Exhausts")
    |> assign(:exhaust, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    exhaust = Garage.Mopeds.get!(Garage.Mopeds.Exhaust, id, actor: socket.assigns.current_user)
    Garage.Mopeds.destroy!(exhaust, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :exhausts, exhaust)}
  end
end
