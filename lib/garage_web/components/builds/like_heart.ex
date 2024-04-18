defmodule GarageWeb.Components.Builds.LikeHeart do
  use GarageWeb, :component

  attr :current_user, :any, required: true
  attr :liked_by_user, :boolean, required: true
  attr :likes, :integer, default: nil
  attr :class, :string

  def like_heart(assigns) do
    ~H"""
    <div class="cursor-pointer">
      <%= if @liked_by_user do %>
        <div phx-click={@current_user && "dislike"}>
          <.button class="w-full">
            <%= if @likes do %>
              <%= @likes %> Likes
            <% else %>
              Unlike
            <% end %>
            <.icon name="hero-heart-solid" class="bg-red-500" />
          </.button>
        </div>
      <% else %>
        <div phx-click={@current_user && "like"}>
          <.button class="w-full" icon="hero-heart">
            <%= if @likes do %>
              <%= @likes %> Likes
            <% else %>
              Like
            <% end %>
          </.button>
        </div>
      <% end %>
    </div>
    """
  end
end
