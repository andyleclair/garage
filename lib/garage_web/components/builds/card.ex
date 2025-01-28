defmodule GarageWeb.Components.Builds.Card do
  @moduledoc false

  use GarageWeb, :component

  attr :build, :any, required: true, doc: "The `Build` struct"

  def card(assigns) do
    ~H"""
    <div class="inline-block rounded-md bg-gray-50 m-1 shadow-md p-2 w-full md:w-72">
      <.link navigate={~p"/builds/#{@build}"}>
        <%= if first_image = @build.images |> List.first() do %>
          <%= if first_image.thumbnail_url do %>
            <img class="object-cover rounded-md w-full h-64" src={first_image.thumbnail_url} alt="" />
          <% else %>
            <img class="object-cover rounded-md w-full h-64" src={first_image.original_url} alt="" />
          <% end %>
        <% else %>
          <%= if @build.image_urls == [] do %>
            <div class="w-full h-64 bg-gray-100 flex items-stretch rounded-md">
              <.icon name="hero-photo" class="m-auto text-gray-300 w-16 h-16" />
            </div>
          <% else %>
            <img
              class="object-cover rounded-md w-full h-64"
              src={List.first(@build.image_urls)}
              alt=""
            />
          <% end %>
        <% end %>
      </.link>

      <div class="p-5">
        <h5 class="truncate mb-2 text-xl font-medium leading-tight text-neutral-800">
          <.link navigate={~p"/builds/#{@build}"}>
            {@build.name}
          </.link>
        </h5>
        <h6>By: <.username user={@build.builder} /></h6>

        {@build.year}
        <.link navigate={~p"/manufacturers/#{@build.manufacturer}"} replace={false}>
          {@build.manufacturer.name}
        </.link>
        <.link navigate={~p"/models/#{@build.model}"}>
          {@build.model.name}
        </.link>
      </div>
    </div>
    """
  end
end
