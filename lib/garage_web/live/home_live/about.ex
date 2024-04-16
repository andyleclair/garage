defmodule GarageWeb.HomeLive.About do
  use GarageWeb, :live_view

  def render(assigns) do
    ~H"""
    <article class="prose lg:prose-xl">
      <h2>
        About Moped.Build
      </h2>
      <p>
        Hi, my name is Andy LeClair, I'm a software engineer by trade, but  on nights
        and weekends I'm one of the Top Guns of the
        <a href="https://www.mopedarmy.com/branches/lslb/">LSLB</a>
        moped club.
      </p>
      <p>
        I thought our community deserved a better way to show off our moped builds, and
        so I built this site.
      </p>
      <p>
        I've been working on this project for a while now, and I'm excited to share it with you!
      </p>
    </article>
    """
  end
end
