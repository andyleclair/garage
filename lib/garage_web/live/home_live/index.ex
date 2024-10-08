defmodule GarageWeb.HomeLive.Index do
  use GarageWeb, :live_view
  import GarageWeb.Components.Builds.Card

  def render(assigns) do
    ~H"""
    <section class="py-6">
      <h2 class="md:text-5xl text-3xl border-b mb-5">
        Welcome to Moped.Club
      </h2>
      <p class="md:text-xl text-lg">
        Moped.Club is a place to share and discover moped builds from around the world!
      </p>
    </section>
    <section class="py-6">
      <h2 class="md:text-4xl text-2xl border-b mb-5">
        Latest Builds
      </h2>

      <div class="columns-2xs">
        <%= for build <- @latest_builds  do %>
          <.card build={build} />
        <% end %>
      </div>
    </section>
    <section class="py-6">
      <h2 class="md:text-4xl text-2xl border-b mb-5">
        Recently Updated Builds
      </h2>
      <div class="columns-2xs">
        <%= for build <- @recently_updated  do %>
          <.card build={build} />
        <% end %>
      </div>
    </section>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, latest_builds} = Garage.Builds.Build.latest_builds()
    {:ok, recently_updated} = Garage.Builds.Build.recently_updated()

    {:ok,
     socket
     |> assign(:latest_builds, latest_builds)
     |> assign(:recently_updated, recently_updated)}
  end
end
