defmodule GarageWeb.Components.Builds.LikeHeart do
  use GarageWeb, :component

  attr :liked_by_user, :boolean, required: true
  attr :class, :string

  def like_heart(assigns) do
    ~H"""
    <div class="cursor-pointer">
      <%= if @liked_by_user do %>
        <div phx-click="dislike">
          <.button class="w-full">
            Unlike <.icon name="hero-heart-solid" class="bg-red-500" />
          </.button>
        </div>
      <% else %>
        <div phx-click="like">
          <.button class="w-full" icon="hero-heart">Like</.button>
        </div>
      <% end %>
    </div>
    """
  end
end
