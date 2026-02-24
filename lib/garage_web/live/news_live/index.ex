defmodule GarageWeb.NewsLive.Index do
  use GarageWeb, :live_view

  def render(assigns) do
    ~H"""
    <section class="py-6">
      <h1 class="md:text-5xl text-3xl border-b mb-5">
        Site News
      </h1>

      <div class="space-y-8">
        <%= for post <- @posts do %>
          <article class="border-b border-zinc-200 pb-8 last:border-b-0">
            <h2 class="md:text-4xl text-2xl font-semibold mb-2">
              {post.title}
            </h2>
            <p class="text-sm text-zinc-500 mb-3">
              {Calendar.strftime(post.date, "%B %d, %Y")} &middot; By {post.author}
            </p>
            <div class="prose prose-zinc max-w-none">
              {raw(post.body)}
            </div>
          </article>
        <% end %>
      </div>

      <%= if @posts == [] do %>
        <p class="text-zinc-500 py-8">
          No news posts yet. Check back later!
        </p>
      <% end %>
    </section>
    """
  end

  def mount(_params, _session, socket) do
    posts = Garage.News.list_posts()

    {:ok,
     socket
     |> assign(:posts, posts)
     |> assign(:page_title, "News")}
  end
end
