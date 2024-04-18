defmodule GarageWeb.Components.Builds.Build do
  @moduledoc false

  use GarageWeb, :component
  import GarageWeb.Components.Builds.LikeHeart
  import GarageWeb.Components.Builds.FollowButton

  attr :build, :any, required: true, doc: "The `Build` struct"
  attr :current_user, :any, required: true

  def build(assigns) do
    ~H"""
    <div class="inline-block rounded-md bg-gray-50 m-1 shadow-md p-2 m-2 w-full md:w-auto">
      <div class="flex flex-col md:flex-row">
        <%= if @build.first_image do %>
          <div class="flex-none">
            <img class="object-cover w-full md:w-64 h-64" src={@build.first_image} alt="" />
          </div>
        <% else %>
          <div class="w-full md:w-64 h-64 bg-gray-100 flex items-stretch rounded-md">
            <.icon name="hero-photo" class="m-auto text-gray-300 w-16 h-16" />
          </div>
        <% end %>

        <div class="flex flex-col gap-y-10 md:gap-y-4 p-2 w-full">
          <div class="flex flex-col md:flex-row justify-between items-baseline">
            <h5 class="flex truncate text-4xl font-black leading-tight text-neutral-800">
              <.link navigate={~p"/builds/#{@build.slug}"}>
                <%= @build.name %>
              </.link>
            </h5>

            <div class="flex flex-col md:flex-row items-baseline justify-between gap-2 w-full md:w-auto">
              <div class="flex flex-row gap-x-2">
                <%= @build.year %>
                <.link patch={~p"/builds?make=#{@build.manufacturer.slug}"}>
                  <%= @build.manufacturer.name %>
                </.link>
                <.link patch={~p"/builds?model=#{@build.model.slug}"}>
                  <%= @build.model.name %>
                </.link>
              </div>
              <div class="grid grid-cols-2 auto-cols-max w-full justify-items-stretch gap-2">
                <.like_heart
                  current_user={@current_user}
                  liked_by_user={@build.liked_by_user}
                  likes={@build.like_count}
                  class="mb-4"
                />
                <.follow_button
                  followed_by_user={@build.followed_by_user}
                  current_user={@current_user}
                  follows={@build.follow_count}
                  class="mb-4"
                />
              </div>
            </div>
          </div>
          <h6>Builder: <.username user={@build.builder} /></h6>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-10">
            <div :if={@build.engine} class="flex flex-row justify-between">
              <div class="font-black">Engine:</div>
              <div>
                <%= @build.engine.manufacturer.name %> <%= @build.engine.name %>
              </div>
            </div>
            <div
              :if={@build.carb_tuning && @build.carb_tuning.carburetor}
              class="flex flex-row justify-between"
            >
              <div class="font-black">Carburetor:</div>
              <div>
                <%= @build.carb_tuning.carburetor.manufacturer.name %> <%= @build.carb_tuning.carburetor.name %>
              </div>
            </div>
            <div :if={@build.exhaust} class="flex flex-row justify-between">
              <div class="font-black">Exhaust:</div>
              <div>
                <%= @build.exhaust.manufacturer.name %> <%= @build.exhaust.name %>
              </div>
            </div>
            <div :if={@build.exhaust} class="flex flex-row justify-between">
              <div class="font-black">Exhaust:</div>
              <div>
                <%= @build.exhaust.manufacturer.name %> <%= @build.exhaust.name %>
              </div>
            </div>
            <div :if={@build.clutch} class="flex flex-row justify-between">
              <div class="font-black">Clutch:</div>
              <div>
                <%= @build.clutch.manufacturer.name %> <%= @build.clutch.name %>
              </div>
            </div>
            <div :if={@build.ignition} class="flex flex-row justify-between">
              <div class="font-black">Ignition:</div>
              <div>
                <%= @build.ignition.manufacturer.name %> <%= @build.ignition.name %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
