defmodule GarageWeb.BuildsLive.Index do
  use GarageWeb, :live_view
  import GarageWeb.Components.Builds.Card

  def render(assigns) do
    ~H"""
    <%= for build <- @builds  do %>
      <.card build={build} />
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, builds} = Garage.Builds.Build.latest_builds()
    {:ok, assign(socket, :builds, builds)}
  end

  def handle_params(%{"make" => make}, _uri, socket) do
    {:ok, builds} = Garage.Builds.Build.by_make(make)
    {:noreply, assign(socket, :builds, builds)}
  end

  def handle_params(%{"model" => model}, _uri, socket) do
    {:ok, builds} = Garage.Builds.Build.by_model(model)
    {:noreply, assign(socket, :builds, builds)}
  end
end
