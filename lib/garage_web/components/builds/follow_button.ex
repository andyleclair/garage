defmodule GarageWeb.Components.Builds.FollowButton do
  use GarageWeb, :component

  attr :followed_by_user, :boolean, required: true
  attr :class, :string

  def follow_button(assigns) do
    ~H"""
    <div class="cursor-pointer w-auto">
      <%= if @followed_by_user do %>
        <div phx-click="unfollow">
          <.button class="w-full">
            Unfollow <.icon name="hero-bolt-solid" class="bg-green-500" />
          </.button>
        </div>
      <% else %>
        <div phx-click="follow">
          <.button class="w-full" icon="hero-bolt">Follow</.button>
        </div>
      <% end %>
    </div>
    """
  end
end
