defmodule GarageWeb.Components.Builds.Card do
  @moduledoc false

  use GarageWeb, :component

  attr :build, :any, required: true, doc: "The `Build` struct"

  def card(assigns) do
    ~H"""
    <div class="inline-block rounded-sm bg-gray-200 m-1 drop-shadow-xl">
      <.a navigate={~p"/builds/#{@build}"}>
        <img class="rounded-t-lg" src="https://placehold.co/400x250" alt="" />

        <div class="p-6">
          <h5 class="mb-2 text-xl font-medium leading-tight text-neutral-800">
            <%= @build.name %>
          </h5>

          <p class="mb-4 text-base text-neutral-600">
            <%= @build.description %>
          </p>
          <%= @build.make %>
          <%= @build.model %>
        </div>
      </.a>
    </div>
    """
  end
end
