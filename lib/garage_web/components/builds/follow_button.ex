defmodule GarageWeb.Components.Builds.FollowButton do
  use GarageWeb, :component

  attr :followed_by_user, :boolean, required: true
  attr :class, :string

  def follow_button(assigns) do
    ~H"""
    <div class="cursor-pointer">
      <%= if @followed_by_user do %>
        <div phx-click="unfollow">
          <.button>
            Unfollow <.icon name="hero-bolt-solid" class="bg-green-500" />
          </.button>
        </div>
      <% else %>
        <div phx-click="follow">
          <.button icon="hero-bolt">follow</.button>
        </div>
      <% end %>
    </div>
    """
  end
end
