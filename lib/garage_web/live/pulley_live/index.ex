defmodule GarageWeb.PulleyLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Pulleys
      <:actions>
        <.link patch={~p"/pulleys/new"}>
          <.button>New Pulley</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="pulleys"
      rows={@streams.pulleys}
      row_click={fn {_id, pulley} -> JS.navigate(~p"/pulleys/#{pulley}") end}
    >
      <:col :let={{_id, pulley}} label="Manufacturer"><%= pulley.manufacturer.name %></:col>

      <:col :let={{_id, pulley}} label="Name"><%= pulley.name %></:col>

      <:col :let={{_id, pulley}} label="Description"><%= pulley.description %></:col>

      <:action :let={{_id, pulley}}>
        <%= if @current_user do %>
          <.link patch={~p"/pulleys/#{pulley}/edit"}>Edit</.link>
        <% end %>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="pulley-modal"
      show
      on_cancel={JS.patch(~p"/pulleys")}
    >
      <.live_component
        module={GarageWeb.PulleyLive.FormComponent}
        id={(@pulley && @pulley.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        pulley={@pulley}
        patch={~p"/pulleys"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :pulleys,
       Ash.read!(Garage.Mopeds.Pulley, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Pulley")
    |> assign(
      :pulley,
      Ash.get!(Garage.Mopeds.Pulley, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Pulley")
    |> assign(:pulley, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pulleys")
    |> assign(:pulley, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    pulley = Ash.get!(Garage.Mopeds.Pulley, id, actor: socket.assigns.current_user)
    Ash.destroy!(pulley, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :pulleys, pulley)}
  end
end
