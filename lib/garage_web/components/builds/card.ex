defmodule GarageWeb.Components.Builds.Card do
  @moduledoc false

  use GarageWeb, :component

  attr :build, :any, required: true, doc: "The `Build` struct"

  def card(assigns) do
    ~H"""
    <div class="inline-block rounded-sm bg-gray-50 m-1 drop-shadow-xl p-2">
      <.link navigate={~p"/builds/#{@build.slug}"}>
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
          <h5 class="mb-2 text-xl font-medium leading-tight text-neutral-800">
            <%= @build.name %>
          </h5>
          <h6>By: <.username user={@build.builder} /></h6>

          <.link patch={~p"/builds?make=#{@build.make}"} replace={false}>
            <%= @build.make.name %>
          </.link>
          <.link patch={~p"/builds?model=#{@build.model}"} replace={false}>
            <%= @build.model.name %>
          </.link>
        </div>
      </.link>
    </div>
    """
  end
end
