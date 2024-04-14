defmodule GarageWeb.Components.Builds.Build do
  @moduledoc false

  use GarageWeb, :component

  attr :build, :any, required: true, doc: "The `Build` struct"

  def build(assigns) do
    ~H"""
    <div class="inline-block rounded-md bg-gray-50 m-1 shadow-md p-2 m-2 w-full md:w-auto">
      <div class="flex flex-col md:flex-row">
        <%= if @build.first_image do %>
          <div class="">
            <img class="object-cover w-64 h-64" src={@build.first_image} alt="" />
          </div>
        <% else %>
          <div class="w-full md:w-64 h-64 bg-gray-100 flex items-stretch rounded-md">
            <.icon name="hero-photo" class="m-auto text-gray-300 w-16 h-16" />
          </div>
        <% end %>

        <div class="p-6">
          <h5 class="truncate mb-2 text-4xl font-medium leading-tight text-neutral-800">
            <.link navigate={~p"/builds/#{@build.slug}"}>
              <%= @build.name %>
            </.link>
          </h5>
          <h6>By: <.username user={@build.builder} /></h6>

          <.link patch={~p"/builds?make=#{@build.manufacturer.slug}"}>
            <%= @build.manufacturer.name %>
          </.link>
          <.link patch={~p"/builds?model=#{@build.model.slug}"}>
            <%= @build.model.name %>
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
