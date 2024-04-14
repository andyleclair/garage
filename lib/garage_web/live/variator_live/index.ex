defmodule GarageWeb.VariatorLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      All Variators
      <:actions>
        <.link patch={~p"/variators/new"}>
          <.button>New Variator</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="variators"
      rows={@streams.variators}
      row_click={fn {_id, variator} -> JS.navigate(~p"/variators/#{variator}") end}
    >
      <:col :let={{_id, variator}} label="Manufacturer"><%= variator.manufacturer.name %></:col>

      <:col :let={{_id, variator}} label="Name"><%= variator.name %></:col>

      <:col :let={{_id, variator}} label="Description"><%= variator.description %></:col>

      <:action :let={{_id, variator}}>
        <%= if @current_user do %>
          <.link patch={~p"/variators/#{variator}/edit"}>Edit</.link>
        <% end %>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="variator-modal"
      show
      on_cancel={JS.patch(~p"/variators")}
    >
      <.live_component
        module={GarageWeb.VariatorLive.FormComponent}
        id={(@variator && @variator.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        variator={@variator}
        patch={~p"/variators"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :variators,
       Ash.read!(Garage.Mopeds.Variator, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Variator")
    |> assign(
      :variator,
      Ash.get!(Garage.Mopeds.Variator, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Variator")
    |> assign(:variator, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "All Variators")
    |> assign(:variator, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    variator = Ash.get!(Garage.Mopeds.Variator, id, actor: socket.assigns.current_user)
    Ash.destroy!(variator, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :variators, variator)}
  end
end
