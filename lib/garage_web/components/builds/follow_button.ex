defmodule GarageWeb.Components.Builds.FollowButton do
  use GarageWeb, :component

  attr :current_user, :any, required: true
  attr :followed_by_user, :boolean, required: true
  attr :follows, :integer, default: nil
  attr :class, :string

  def follow_button(assigns) do
    ~H"""
    <div class="cursor-pointer w-auto">
      <%= if not is_struct(@followed_by_user, Ash.NotLoaded) and @followed_by_user do %>
        <div phx-click={if @current_user, do: "unfollow", else: "login"}>
          <.button class="w-full">
            Unfollow <.icon name="hero-bolt-solid" class="bg-green-500" />
          </.button>
        </div>
      <% else %>
        <div phx-click={if @current_user, do: "follow", else: "login"}>
          <.button class="w-full" icon="hero-bolt">
            Follow
          </.button>
        </div>
      <% end %>
    </div>
    """
  end
end
