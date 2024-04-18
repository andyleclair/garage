defmodule GarageWeb.Components.Builds.FollowButton do
  use GarageWeb, :component

  attr :current_user, :any, required: true
  attr :followed_by_user, :boolean, required: true
  attr :follows, :integer, default: nil
  attr :class, :string

  def follow_button(assigns) do
    ~H"""
    <div class="cursor-pointer w-auto">
      <%= if @followed_by_user do %>
        <div phx-click={@current_user && "unfollow"}>
          <.button class="w-full">
            <%= if @follows do %>
              <%= @follows %> Follows
            <% else %>
              Unfollow
            <% end %>
            <.icon name="hero-bolt-solid" class="bg-green-500" />
          </.button>
        </div>
      <% else %>
        <div phx-click={@current_user && "follow"}>
          <.button class="w-full" icon="hero-bolt">
            <%= if @follows do %>
              <%= @follows %> Follows
            <% else %>
              Follow
            <% end %>
          </.button>
        </div>
      <% end %>
    </div>
    """
  end
end
