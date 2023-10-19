defmodule GarageWeb.HomeLive.Index do
  use GarageWeb, :live_view
  import GarageWeb.Components.Builds.Card

  def mount(_params, _session, socket) do
    {:ok, builds} = Garage.Builds.Build.latest_builds()
    {:ok, assign(socket, :latest_builds, builds)}
  end
end
