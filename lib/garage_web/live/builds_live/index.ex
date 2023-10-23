defmodule GarageWeb.BuildsLive.Index do
  use GarageWeb, :live_view

  alias Garage.Builds.Build
  alias Ash.Page.Offset, as: Page
  import GarageWeb.Components.Builds.Build

  @impl true
  def mount(_params, _session, socket) do
    {:ok, %Page{results: builds}} = Build.all_builds()
    {:ok, assign(socket, :builds, builds)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"make" => make}) do
    {:ok, builds} = Build.by_make(make)

    socket
    |> assign(:builds, builds)
    |> assign(:page_title, "Listing Builds - #{make}")
    |> assign(:build, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Builds")
    |> assign(:build, nil)
  end
end
