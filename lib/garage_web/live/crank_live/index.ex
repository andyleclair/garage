defmodule GarageWeb.CrankLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      All Cranks
      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/cranks/new"}>
            <.button>New Crank</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.table
      id="cranks"
      rows={@streams.cranks}
      row_click={fn {_id, crank} -> JS.navigate(~p"/cranks/#{crank}") end}
    >
      <:col :let={{_id, crank}} label="Manufacturer">
        <.link navigate={~p"/manufacturers/#{crank.manufacturer}"}>
          <%= crank.manufacturer.name %>
        </.link>
      </:col>
      <:col :let={{_id, crank}} label="Name"><%= crank.name %></:col>
      <:col :let={{_id, crank}} label="Engine">
        <%= if crank.engine do %>
          <.link navigate={~p"/engines/#{crank.engine}"}>
            <%= crank.engine.name %>
          </.link>
        <% end %>
      </:col>

      <:col :let={{_id, crank}} label="Description"><%= crank.description %></:col>

      <:col :let={{_id, crank}} label="Stroke"><%= if crank.stroke, do: "#{crank.stroke} mm" %></:col>

      <:col :let={{_id, crank}} label="Conrod length">
        <%= if crank.conn_rod_length, do: "#{crank.conn_rod_length} mm" %>
      </:col>

      <:col :let={{_id, crank}} label="Small end bearing diameter">
        <%= if crank.small_end_bearing_diameter, do: "#{crank.small_end_bearing_diameter} mm" %>
      </:col>

      <:action :let={{_id, crank}}>
        <%= if @current_user do %>
          <.link patch={~p"/cranks/#{crank}/edit"}>Edit</.link>
        <% end %>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="crank-modal"
      show
      on_cancel={JS.patch(~p"/cranks")}
    >
      <.live_component
        module={GarageWeb.CrankLive.FormComponent}
        id={(@crank && @crank.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        crank={@crank}
        patch={~p"/cranks"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :cranks,
       Ash.read!(Garage.Mopeds.Crank, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Crank")
    |> assign(
      :crank,
      Ash.get!(Garage.Mopeds.Crank, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Crank")
    |> assign(:crank, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "All Cranks")
    |> assign(:crank, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    crank = Ash.get!(Garage.Mopeds.Crank, id, actor: socket.assigns.current_user)
    Ash.destroy!(crank, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :cranks, crank)}
  end
end
