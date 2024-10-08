defmodule GarageWeb.ModelLive.Index do
  use GarageWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      All Moped Models
      <:actions>
        <%= if @current_user do %>
          <.link patch={~p"/models/new"}>
            <.button>New Model</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.table id="models" rows={@models} row_click={fn model -> JS.navigate(~p"/models/#{model}") end}>
      <:col :let={model} label="Manufacturer"><%= model.manufacturer.name %></:col>
      <:col :let={model} label="Name"><%= model.name %></:col>
      <:col :let={model} label="Description"><%= model.description %></:col>

      <:action :let={model}>
        <%= if @current_user do %>
          <.link patch={~p"/models/#{model}/edit"}>Edit</.link>
        <% end %>
      </:action>
    </.table>

    <.pagination
      id="pagination"
      page_number={@active_page}
      page_size={@page_limit}
      entries_length={length(@models)}
      total_entries={@total_entries}
      total_pages={@pages}
    />

    <.modal
      :if={@live_action in [:new, :edit]}
      id="model-modal"
      show
      on_cancel={JS.patch(~p"/models")}
    >
      <.live_component
        module={GarageWeb.ModelLive.FormComponent}
        id={(@model && @model.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        model={@model}
        patch={~p"/models"}
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
     |> assign(:models, [])
     |> assign(:total_entries, 0)
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Model")
    |> assign(
      :model,
      Ash.get!(Garage.Mopeds.Model, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Model")
    |> assign(:model, nil)
  end

  defp apply_action(socket, :index, params) do
    active_page = page(params["page"])
    offset = page_offset(active_page, socket.assigns.page_limit)
    {:ok, page} = load_page(socket.assigns.page_limit, offset)

    socket
    |> assign(:page_title, "All Models")
    |> assign(:pages, ceil(page.count / socket.assigns.page_limit))
    |> assign(:total_entries, page.count)
    |> assign(:models, page.results)
    |> assign(:active_page, active_page)
    |> assign(:page_offset, offset)
    |> assign(:model, nil)
  end

  def load_page(limit, offset) do
    Garage.Mopeds.Model.all_models(page: [limit: limit, offset: offset, count: true])
  end
end
