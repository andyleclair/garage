defmodule GarageWeb.BuildsLive.Index do
  use GarageWeb, :live_view

  alias Garage.Builds.Build
  import GarageWeb.Components.Builds.Build

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      All Builds
    </.header>

    <div class="flex flex-col"><.build :for={build <- @builds} build={build} /></div>

    <.pagination
      id="pagination"
      page_number={@active_page}
      page_size={@page_limit}
      entries_length={length(@builds)}
      total_entries={@total_entries}
      total_pages={@pages}
    />
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

  defp apply_action(socket, :index, %{"manufacturer" => manufacturer}) do
    {:ok, builds} = Build.by_manufacturer(manufacturer)

    socket
    |> assign(:builds, builds)
    |> assign(:page_title, "All Builds - #{manufacturer}")
  end

  defp apply_action(socket, :index, %{"model" => model}) do
    {:ok, builds} = Build.by_model(model)

    socket
    |> assign(:builds, builds)
    |> assign(:page_title, "All Builds - #{model}")
  end

  defp apply_action(socket, :index, params) do
    active_page = page(params["page"])
    offset = page_offset(active_page, socket.assigns.page_limit)
    {:ok, page} = load_page(socket.assigns.page_limit, offset)

    socket
    |> assign(:pages, ceil(page.count / socket.assigns.page_limit))
    |> assign(:total_entries, page.count)
    |> assign(:builds, page.results)
    |> assign(:active_page, active_page)
    |> assign(:page_offset, offset)
    |> assign(:page_title, "All Builds")
  end

  def load_page(limit, offset) do
    Garage.Builds.Build.all_builds(page: [limit: limit, offset: offset, count: true])
  end
end
