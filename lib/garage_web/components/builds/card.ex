defmodule GarageWeb.Components.Builds.Card do
  @moduledoc false

  use GarageWeb, :component

  attr :build, :any, required: true, doc: "The `Build` struct"

  def card(assigns) do
    ~H"""
    <div class="inline-block rounded-md bg-gray-50 m-1 shadow-md p-2 w-full md:w-72">
      <.link navigate={~p"/builds/#{@build.slug}"}>
        <%= if @build.first_image do %>
          <img class="object-cover w-full h-64 rounded-md" src={@build.first_image} alt="" />
        <% else %>
          <div class="w-full h-64 bg-gray-100 flex items-stretch rounded-md">
            <div class="mt-2 ml-2 text-xl uppercase">No Images Yet</div>
          </div>
        <% end %>
      </.link>

      <div class="p-5">
        <h5 class="mb-2 text-xl font-medium leading-tight text-neutral-800">
          <.link navigate={~p"/builds/#{@build.slug}"}>
            <%= @build.name %>
          </.link>
        </h5>
        <h6>By: <.username user={@build.builder} /></h6>

        <%= @build.year %>
        <.link patch={~p"/builds?make=#{@build.manufacturer.slug}"} replace={false}>
          <%= @build.manufacturer.name %>
        </.link>
        <.link
          patch={~p"/builds?#{[make: @build.manufacturer.slug, model: @build.model.slug]}"}
          replace={false}
        >
          <%= @build.model.name %>
        </.link>
      </div>
    </div>
    """
  end
end
