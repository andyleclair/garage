defmodule GarageWeb.ExhaustLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      All Exhausts
      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/exhausts/new"}>
            <.button>New Exhaust</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.table
      id="exhausts"
      rows={@exhausts}
      row_click={fn exhaust -> JS.navigate(~p"/exhausts/#{exhaust}") end}
    >
      <:col :let={exhaust} label="Manufacturer"><%= exhaust.manufacturer.name %></:col>

      <:col :let={exhaust} label="Name"><%= exhaust.name %></:col>

      <:col :let={exhaust} label="Description"><%= exhaust.description %></:col>

      <:action :let={exhaust}>
        <%= if @current_user do %>
          <.link patch={~p"/exhausts/#{exhaust}/edit"}>Edit</.link>
        <% end %>
      </:action>
    </.table>

    <.pagination
      id="pagination"
      page_number={@active_page}
      page_size={@page_limit}
      entries_length={length(@exhausts)}
      total_entries={@total_entries}
      total_pages={@pages}
    />

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
    |> assign(:page_title, "Edit Exhaust")
    |> assign(
      :exhaust,
      Ash.get!(Garage.Mopeds.Exhaust, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Exhaust")
    |> assign(:exhaust, nil)
  end

  defp apply_action(socket, :index, params) do
    active_page = page(params["page"])
    offset = page_offset(active_page, socket.assigns.page_limit)
    {:ok, page} = load_page(socket.assigns.page_limit, offset)

    socket
    |> assign(:pages, ceil(page.count / socket.assigns.page_limit))
    |> assign(:total_entries, page.count)
    |> assign(:exhausts, page.results)
    |> assign(:active_page, active_page)
    |> assign(:page_offset, offset)
    |> assign(:page_title, "All Exhausts")
    |> assign(:exhaust, nil)
  end

  def load_page(limit, offset) do
    Garage.Mopeds.Exhaust.read_all(page: [limit: limit, offset: offset, count: true])
  end
end
