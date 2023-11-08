defmodule GarageWeb.Components.Builds.LikeHeart do
  use GarageWeb, :component

  attr :liked_by_user, :boolean, required: true
  attr :class, :string, default: "", doc: "class to set the width and height of the icon"

  def like_heart(assigns) do
    ~H"""
    <div>
      <%= if @liked_by_user do %>
        <div phx-click="dislike" class="text-red-600">
          <.icon name="hero-heart" class={@class} />
        </div>
      <% else %>
        <div phx-click="like">
          <.icon name="hero-heart" class={@class} />
        </div>
      <% end %>
    </div>
    """
  end
end
