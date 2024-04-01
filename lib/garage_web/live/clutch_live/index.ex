defmodule GarageWeb.ClutchLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Clutches
      <:actions>
        <.link patch={~p"/clutches/new"}>
          <.button>New Clutch</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="clutches"
      rows={@streams.clutches}
      row_click={fn {_id, clutch} -> JS.navigate(~p"/clutches/#{clutch}") end}
    >
      <:col :let={{_id, clutch}} label="Manufacturer"><%= clutch.manufacturer.name %></:col>
      <:col :let={{_id, clutch}} label="Name"><%= clutch.name %></:col>

      <:col :let={{_id, clutch}} label="Description"><%= clutch.description %></:col>

      <:action :let={{_id, clutch}}>
        <div class="sr-only">
          <.link navigate={~p"/clutches/#{clutch}"}>Show</.link>
        </div>

        <.link patch={~p"/clutches/#{clutch}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, clutch}}>
        <.link
          phx-click={JS.push("delete", value: %{id: clutch.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="clutch-modal"
      show
      on_cancel={JS.patch(~p"/clutches")}
    >
      <.live_component
        module={GarageWeb.ClutchLive.FormComponent}
        id={(@clutch && @clutch.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        clutch={@clutch}
        patch={~p"/clutches"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :clutches,
       Garage.Mopeds.read!(Garage.Mopeds.Clutch, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Clutch")
    |> assign(
      :clutch,
      Garage.Mopeds.get!(Garage.Mopeds.Clutch, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Clutch")
    |> assign(:clutch, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Clutches")
    |> assign(:clutch, nil)
  end

  @impl true
  def handle_info({GarageWeb.ClutchLive.FormComponent, {:saved, clutch}}, socket) do
    # todo: make this not reload
    clutch =
      Garage.Mopeds.get!(Garage.Mopeds.Clutch, clutch.id, actor: socket.assigns.current_user)

    {:noreply, stream_insert(socket, :clutches, clutch)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    clutch = Garage.Mopeds.get!(Garage.Mopeds.Clutch, id, actor: socket.assigns.current_user)
    Garage.Mopeds.destroy!(clutch, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :clutches, clutch)}
  end
end
