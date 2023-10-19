defmodule GarageWeb.BuildsLive.Index do
  use GarageWeb, :live_view
  import GarageWeb.Components.Builds.Card

  def render(assigns) do
    ~H"""
    <%= for build <- @latest_builds  do %>
      <.card build={build} />
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, builds} = Garage.Builds.Build.latest_builds()
    {:ok, assign(socket, :latest_builds, builds)}
  end
end
