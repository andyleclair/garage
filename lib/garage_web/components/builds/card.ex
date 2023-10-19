defmodule GarageWeb.Components.Builds.Card do
  @moduledoc false

  use GarageWeb, :component

  import Pyro.Components.Extra, only: [a: 1]

  attr :build, :any, required: true, doc: "The `Build` struct"

  def card(assigns) do
    ~H"""
    <div class="inline-block rounded-lg bg-white shadow-[0_2px_15px_-3px_rgba(0,0,0,0.07),0_10px_20px_-2px_rgba(0,0,0,0.04)] dark:bg-neutral-700">
      <.a navigate={~p"/builds/#{@build}"}>
        <img class="rounded-t-lg" src="https://placehold.co/400x250" alt="" />

        <div class="p-6">
          <h5 class="mb-2 text-xl font-medium leading-tight text-neutral-800 dark:text-neutral-50">
            <%= @build.name %>
          </h5>

          <p class="mb-4 text-base text-neutral-600 dark:text-neutral-200">
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
