defmodule GarageWeb.Components.Builds.Card do
  @moduledoc false

  use GarageWeb, :component

  attr :build, :any, required: true, doc: "The `Build` struct"

  def card(assigns) do
    ~H"""
    <div class="inline-block rounded-sm bg-gray-50 m-1 drop-shadow-xl p-2">
      <.a navigate={~p"/builds/#{@build}"}>
        <img class="rounded-t-lg" src="https://placehold.co/400x250" alt="" />

        <div class="p-6">
          <h5 class="mb-2 text-xl font-medium leading-tight text-neutral-800">
            <%= @build.name %>
          </h5>

          <.a patch={~p"/builds?make=#{@build.make}"} replace={false}>
            <%= @build.make %>
          </.a>
          <.a patch={~p"/builds?model=#{@build.model}"} replace={false}>
            <%= @build.model %>
          </.a>
        </div>
      </.a>
    </div>
    """
  end
end
