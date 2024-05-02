defmodule GarageWeb.Components.Builds.Build do
  @moduledoc false

  use GarageWeb, :component

  attr :build, :any, required: true, doc: "The `Build` struct"
  attr :current_user, :any, required: true

  def build(assigns) do
    ~H"""
    <div class="inline-block rounded-md bg-gray-50 shadow-md p-2 w-full md:w-auto">
      <div class="flex flex-col md:flex-row">
        <%= if @build.first_image do %>
          <div class="flex-none">
            <img class="object-cover rounded-md w-full md:w-64 h-64" src={@build.first_image} alt="" />
          </div>
        <% else %>
          <div class="flex-none w-full md:w-64 h-64 bg-gray-100 flex items-stretch rounded-md">
            <.icon name="hero-photo" class="m-auto text-gray-300 w-16 h-16" />
          </div>
        <% end %>

        <div class="flex flex-col gap-y-10 md:gap-y-4 ml-2 w-full">
          <div class="flex flex-col md:flex-row justify-between items-baseline border-b border-neutral-800">
            <h5 class="flex truncate text-4xl font-black leading-tight text-neutral-800">
              <.link navigate={~p"/builds/#{@build.slug}"} class="truncate w-full max-w-md">
                <%= @build.name %>
              </.link>
            </h5>

            <div class="flex flex-col md:flex-row divide-x items-baseline justify-between gap-2 w-full md:w-auto ">
              <div class="flex flex-row flex-none inline-block gap-x-2">
                <%= @build.year %>
                <.link patch={~p"/builds?#{[make: @build.manufacturer]}"}>
                  <%= @build.manufacturer.name %>
                </.link>
                <.link patch={~p"/builds?#{[make: @build.manufacturer, model: @build.model]}"}>
                  <%= @build.model.name %>
                </.link>
              </div>
              <div class="grid grid-cols-3 auto-cols-max w-full justify-items-stretch gap-x-2 px-2">
                <div>
                  <%= @build.like_count %> <.icon name="hero-heart-solid" class="bg-red-500" />
                </div>
                <div>
                  <%= @build.follow_count %> <.icon name="hero-bolt-solid" class="bg-green-500" />
                </div>
                <div>
                  <%= @build.comment_count %>
                  <.icon name="hero-chat-bubble-bottom-center-solid" class="bg-blue-500" />
                </div>
              </div>
            </div>
          </div>
          <h6><span class="font-semibold">Builder:</span> <.username user={@build.builder} /></h6>

          <div class="grid grid-cols-1 p-2 md:grid-cols-2 gap-4">
            <div
              :if={@build.engine_tuning && @build.engine_tuning.engine}
              class="flex flex-row justify-between"
            >
              <div class="font-semibold">Engine:</div>
              <div>
                <%= @build.engine_tuning.engine.manufacturer.name %> <%= @build.engine_tuning.engine.name %>
              </div>
            </div>
            <div
              :if={@build.carb_tuning && @build.carb_tuning.carburetor}
              class="flex flex-row justify-between"
            >
              <div class="font-semibold">Carburetor:</div>
              <div>
                <%= @build.carb_tuning.carburetor.manufacturer.name %> <%= @build.carb_tuning.carburetor.name %>
              </div>
            </div>
            <div
              :if={@build.cylinder_tuning && @build.cylinder_tuning.cylinder}
              class="flex flex-row justify-between"
            >
              <div class="font-semibold">Cylinder:</div>
              <div>
                <%= @build.cylinder_tuning.cylinder.manufacturer.name %> <%= @build.cylinder_tuning.cylinder.name %>
              </div>
            </div>
            <div :if={@build.exhaust} class="flex flex-row justify-between">
              <div class="font-semibold">Exhaust:</div>
              <div>
                <%= @build.exhaust.manufacturer.name %> <%= @build.exhaust.name %>
              </div>
            </div>
            <div
              :if={@build.clutch_tuning && @build.clutch_tuning.clutch}
              class="flex flex-row justify-between"
            >
              <div class="font-semibold">Clutch:</div>
              <div>
                <%= @build.clutch_tuning.clutch.manufacturer.name %> <%= @build.clutch_tuning.clutch.name %>
              </div>
            </div>
            <div
              :if={@build.ignition_tuning && @build.ignition_tuning.ignition}
              class="flex flex-row justify-between"
            >
              <div class="font-semibold">Ignition:</div>
              <div>
                <%= @build.ignition_tuning.ignition.manufacturer.name %> <%= @build.ignition_tuning.ignition.name %>
              </div>
            </div>
            <div
              :if={@build.variator_tuning && @build.variator_tuning.variator}
              class="flex flex-row justify-between"
            >
              <div class="font-semibold">Variator:</div>
              <div>
                <%= @build.variator_tuning.variator.manufacturer.name %> <%= @build.variator_tuning.variator.name %>
              </div>
            </div>
            <div :if={@build.pulley} class="flex flex-row justify-between">
              <div class="font-semibold">Pulley:</div>
              <div>
                <%= @build.pulley.manufacturer.name %> <%= @build.pulley.name %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
