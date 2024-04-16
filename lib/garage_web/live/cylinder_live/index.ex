defmodule GarageWeb.CylinderLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      All Cylinders
      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/cylinders/new"}>
            <.button>New Cylinder</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.table
      id="cylinders"
      rows={@cylinders}
      row_click={fn cylinder -> JS.navigate(~p"/cylinders/#{cylinder}") end}
    >
      <:col :let={cylinder} label="Manufacturer">
        <.link navigate={~p"/manufacturers/#{cylinder.manufacturer}"}>
          <%= cylinder.manufacturer.name %>
        </.link>
      </:col>
      <:col :let={cylinder} label="Name"><%= cylinder.name %></:col>

      <:col :let={cylinder} label="Description"><%= cylinder.description %></:col>

      <:col :let={cylinder} label="Displacement">
        <.badge :if={cylinder.displacement}><%= cylinder.displacement %> cc</.badge>
      </:col>
      <:col :let={cylinder} label="Bore">
        <.badge :if={cylinder.bore}><%= cylinder.bore %> mm</.badge>
      </:col>

      <:action :let={cylinder}>
        <%= if @current_user do %>
          <.link patch={~p"/cylinders/#{cylinder}/edit"}>Edit</.link>
        <% end %>
      </:action>
    </.table>

    <.pagination
      id="pagination"
      page_number={@active_page}
      page_size={@page_limit}
      entries_length={length(@cylinders)}
      total_entries={@total_entries}
      total_pages={@pages}
    />

    <.modal
      :if={@live_action in [:new, :edit]}
      id="cylinder-modal"
      show
      on_cancel={JS.patch(~p"/cylinders")}
    >
      <.live_component
        module={GarageWeb.CylinderLive.FormComponent}
        id={(@cylinder && @cylinder.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        cylinder={@cylinder}
        patch={~p"/cylinders"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_offset, 0)
     |> assign(:page_limit, 30)
     |> assign(:pages, 0)
     |> assign(:active_page, 1)
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Cylinder")
    |> assign(
      :cylinder,
      Ash.get!(Garage.Mopeds.Cylinder, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Cylinder")
    |> assign(:cylinder, nil)
  end

  defp apply_action(socket, :index, params) do
    active_page = page(params["page"])
    offset = page_offset(active_page, socket.assigns.page_limit)
    {:ok, page} = load_page(socket.assigns.page_limit, offset)

    socket
    |> assign(:pages, ceil(page.count / socket.assigns.page_limit))
    |> assign(:total_entries, page.count)
    |> assign(:cylinders, page.results)
    |> assign(:active_page, active_page)
    |> assign(:page_offset, offset)
    |> assign(:page_title, "All Cylinders")
    |> assign(:cylinder, nil)
  end

  def load_page(limit, offset) do
    Garage.Mopeds.Cylinder.read_all(page: [limit: limit, offset: offset, count: true])
  end
end
