defmodule GarageWeb.HomeLive.Index do
  use GarageWeb, :live_view
  import GarageWeb.Components.Builds.Card

  def render(assigns) do
    ~H"""
    <section class="py-6">
      <div class="flex items-center justify-between border-b mb-5">
        <h2 class="md:text-4xl text-2xl">
          Site News
        </h2>
        <.link
          navigate={~p"/news"}
          class="text-sm text-zinc-600 hover:text-zinc-900"
        >
          View all news &rarr;
        </.link>
      </div>
      <div class="grid gap-6 md:grid-cols-3">
        <%= for post <- @news_posts do %>
          <article class="border border-zinc-200 rounded-lg p-4 hover:shadow-md transition-shadow">
            <.link navigate={~p"/news"} class="block">
              <h3 class="text-lg font-semibold mb-2 hover:text-zinc-600">
                {post.title}
              </h3>
              <p class="text-sm text-zinc-500 mb-2">
                {Calendar.strftime(post.date, "%B %d, %Y")} &middot; {post.author}
              </p>
              <p class="text-sm text-zinc-600">
                {post.excerpt}
              </p>
            </.link>
          </article>
        <% end %>
      </div>
    </section>

    <section class="py-6">
      <h2 class="md:text-4xl text-2xl border-b mb-5">
        Latest Builds
      </h2>

      <div class="grid grid-cols-3 justify-items-center gap-y-8">
        <%= for build <- @latest_builds  do %>
          <.card build={build} />
        <% end %>
      </div>
    </section>

    <section class="py-6">
      <h2 class="md:text-4xl text-2xl border-b mb-5">
        Recently Updated Builds
      </h2>
      <div class="grid grid-cols-3 justify-items-center gap-y-8">
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
    news_posts = Garage.News.latest_posts(3)

    {:ok,
     socket
     |> assign(:latest_builds, latest_builds)
     |> assign(:recently_updated, recently_updated)
     |> assign(:news_posts, news_posts)
     |> assign(:page_title, "Home")}
  end
end
