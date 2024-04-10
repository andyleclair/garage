defmodule GarageWeb.HomeLive.About do
  use GarageWeb, :live_view

  def render(assigns) do
    ~H"""
    <section class="py-6">
      <h2 class="md:text-5xl text-3xl border-b mb-5">
        About Moped.Build
      </h2>
      <p class="md:text-xl text-lg">
        Moped.Build is a place to share and discover moped builds from around the world!
      </p>
    </section>
    """
  end
end
