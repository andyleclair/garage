defmodule GarageWeb.PartsLive.Index do
  use GarageWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        All Parts
      </.header>

      <div class="flex flex-col gap-10">
        <.link navigate={~p"/manufacturers"}>Manufacturers</.link>
        <.link navigate={~p"/models"}>Moped Models</.link>
        <.link navigate={~p"/engines"}>Engines</.link>
        <.link navigate={~p"/clutches"}>Clutches</.link>
        <.link navigate={~p"/cylinders"}>Cylinders</.link>
        <.link navigate={~p"/carburetors"}>Carburetors</.link>
        <.link navigate={~p"/cranks"}>Crankshafts</.link>
        <.link navigate={~p"/cylinders"}>Cylinders</.link>
        <.link navigate={~p"/exhausts"}>Exhausts</.link>
        <.link navigate={~p"/ignitions"}>Ignitions</.link>
        <.link navigate={~p"/variators"}>Variators</.link>
        <.link navigate={~p"/pulleys"}>Pulleys</.link>
      </div>
    </div>
    """
  end
end
