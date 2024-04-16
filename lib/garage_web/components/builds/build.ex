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
          <div class="flex flex-row justify-between">
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

          <div class="grid grid-cols-1 md:grid-cols-3 gap-10">
            <div class="flex flex-row justify-between">
              <div class="font-black">Engine:</div>
              <div :if={@build.engine}>
                <%= @build.engine.manufacturer.name %> <%= @build.engine.name %>
              </div>
            </div>
            <div class="flex flex-row justify-between">
              <div class="font-black">Carburetor:</div>
              <div :if={@build.carb_tuning && @build.carb_tuning.carburetor}>
                <%= @build.carb_tuning.carburetor.manufacturer.name %> <%= @build.carb_tuning.carburetor.name %>
              </div>
            </div>
            <div class="flex flex-row justify-between">
              <div class="font-black">Exhaust:</div>
              <div :if={@build.exhaust}>
                <%= @build.exhaust.manufacturer.name %> <%= @build.exhaust.name %>
              </div>
            </div>
            <div class="flex flex-row justify-between">
              <div class="font-black">Exhaust:</div>
              <div :if={@build.exhaust}>
                <%= @build.exhaust.manufacturer.name %> <%= @build.exhaust.name %>
              </div>
            </div>
            <div class="flex flex-row justify-between">
              <div class="font-black">Clutch:</div>
              <div :if={@build.clutch}>
                <%= @build.clutch.manufacturer.name %> <%= @build.clutch.name %>
              </div>
            </div>
            <div class="flex flex-row justify-between">
              <div class="font-black">Ignition:</div>
              <div :if={@build.ignition}>
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
