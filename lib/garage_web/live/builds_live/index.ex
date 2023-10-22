defmodule GarageWeb.BuildsLive.Index do
  use GarageWeb, :live_view

  alias Garage.Builds
  alias Garage.Builds.Build
  alias Ash.Page.Offset, as: Page

  @impl true
  def mount(_params, _session, socket) do
    {:ok, %Page{results: builds}} = Build.all_builds()
    {:ok, assign(socket, :builds, builds)}
  end

  # def handle_params(%{"model" => model}, _uri, socket) do
  #  {:ok, builds} = Garage.Builds.by_model(model)
  #  {:noreply, assign(socket, :builds, builds)}
  # end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Build")
    |> assign(:build, Build.get_build!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Build")
    |> assign(:build, %Build{})
  end

  defp apply_action(socket, :index, %{"make" => make}) do
    builds = Build.by_make(make)
    dbg(builds)

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

  @impl true
  def handle_info({GarageWeb.BuildLive.FormComponent, {:saved, build}}, socket) do
    {:noreply, stream_insert(socket, :builds, build)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    build = Build.get_build!(id)
    {:ok, _} = Build.delete_build(build)

    {:noreply, stream_delete(socket, :builds, build)}
  end
end
