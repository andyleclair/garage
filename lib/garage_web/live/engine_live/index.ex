defmodule GarageWeb.EngineLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      All Engines
      <:actions>
        <.link patch={~p"/engines/new"}>
          <.button>New Engine</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="engines"
      rows={@streams.engines}
      row_click={fn {_id, engine} -> JS.navigate(~p"/engines/#{engine}") end}
    >
      <:col :let={{_id, engine}} label="Manufacturer">
        <.link navigate={~p"/manufacturers/#{engine.manufacturer}"}>
          <%= engine.manufacturer.name %>
        </.link>
      </:col>
      <:col :let={{_id, engine}} label="Name"><%= engine.name %></:col>
      <:col :let={{_id, engine}} label="Description"><%= engine.description %></:col>
      <:col :let={{_id, engine}} label="Transmission">
        <%= engine.transmission |> humanize() %>
      </:col>

      <:action :let={{_id, engine}}>
        <div class="sr-only">
          <.link navigate={~p"/engines/#{engine}"}>Show</.link>
        </div>

        <.link patch={~p"/engines/#{engine}/edit"}>Edit</.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="engine-modal"
      show
      on_cancel={JS.patch(~p"/engines")}
    >
      <.live_component
        module={GarageWeb.EngineLive.FormComponent}
        id={(@engine && @engine.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        engine={@engine}
        patch={~p"/engines"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :engines,
       Ash.read!(Garage.Mopeds.Engine, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Engine")
    |> assign(
      :engine,
      Ash.get!(Garage.Mopeds.Engine, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Engine")
    |> assign(:engine, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "All Engines")
    |> assign(:engine, nil)
  end

  @impl true
  def handle_info({GarageWeb.EngineLive.FormComponent, {:saved, engine}}, socket) do
    engine =
      Ash.get!(Garage.Mopeds.Engine, engine.id, actor: socket.assigns.current_user)

    {:noreply, stream_insert(socket, :engines, engine)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    engine = Ash.get!(Garage.Mopeds.Engine, id, actor: socket.assigns.current_user)
    Ash.destroy!(engine, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :engines, engine)}
  end
end
