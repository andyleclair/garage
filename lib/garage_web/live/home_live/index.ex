defmodule GarageWeb.HomeLive.Index do
  use GarageWeb, :live_view

  def mount(_params, _session, socket) do
    builds = Garage.Builds.Build.latest_builds()
    {:ok, assign(socket, :latest_builds, builds), layout: false}
  end
end
