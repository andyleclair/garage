defmodule GarageWeb.BuildsLive.New do
  use GarageWeb, :live_view

  alias Garage.Builds.Build
  alias GarageWeb.BuildsLive.FormComponent

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component
      module={FormComponent}
      id={@build.id || :new}
      title={@page_title}
      action={@live_action}
      build={@build}
      current_user={@current_user}
    />

    <.back navigate={~p"/builds"}>Back to builds</.back>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "New Build")
     |> assign(:build, %Build{})}
  end
end
