defmodule GarageWeb.HomeLive.Privacy do
  use GarageWeb, :live_view

  def render(assigns) do
    ~H"""
    <article class="prose lg:prose-xl">
      <h2>
        Privacy Policy
      </h2>
      <p>
        Here's the deal: I'm not going to sell your data. I'm not going to share your data.
        I'm not going to use your data for anything other than running this site.
      </p>
      <p>
        I'm not going to track you, I'm not going to use cookies, I'm not going to use Google Analytics.
        I'm not going to use any third party services that might track you.
      </p>
      <p>
        I'm not going to send you any email unless you ask me to.
      </p>
      <p>If you want to delete your account, just let me know and I'll take care of it.</p>
    </article>
    """
  end
end
