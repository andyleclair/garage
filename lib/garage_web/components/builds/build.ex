defmodule GarageWeb.Components.Builds.Build do
  @moduledoc false

  use GarageWeb, :component

  attr :build, :any, required: true, doc: "The `Build` struct"

  def build(assigns) do
    ~H"""
    <div class="inline-block rounded-sm bg-gray-50 m-1 shadow-md p-2 m-2 w-full">
      <div class="flex flex-row">
        <%= if @build.first_image do %>
          <div class="">
            <img class="object-cover w-64 h-64" src={@build.first_image} alt="" />
          </div>
        <% else %>
          <div class="w-64 h-64 bg-gray-300 flex items-stretch">
            <div class="mt-2 ml-2 text-xl uppercase">No Images</div>
          </div>
        <% end %>

        <div class="p-6">
          <h5 class="mb-2 text-4xl font-medium leading-tight text-neutral-800">
            <.link navigate={~p"/builds/#{@build.slug}"}>
              <%= @build.name %>
            </.link>
          </h5>
          <h6>By: <.username user={@build.builder} /></h6>

          <.link patch={~p"/builds?make=#{@build.make.slug}"}>
            <%= @build.make.name %>
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
