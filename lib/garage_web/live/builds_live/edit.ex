defmodule GarageWeb.BuildsLive.Edit do
  alias Garage.Builds.Build
  use GarageWeb, :live_view

  alias GarageWeb.BuildsLive.FormComponent

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component
      module={FormComponent}
      id={@build.id}
      title={@page_title}
      action={@live_action}
      build={@build}
      current_user={@current_user}
    />

    <.back navigate={~p"/builds/#{@build}"}>Back to build</.back>
    """
  end

  @impl true
  def mount(%{"build_id" => build_id}, _session, socket) do
    build = Build.get_by_id!(build_id)

    if Build.can_update?(socket.assigns.current_user, build) do
      {:ok,
       socket
       |> assign(:page_title, "Edit Build")
       |> assign(:build, build)}
    else
      {:ok, socket |> put_flash(:error, "Naughty! 😈") |> push_navigate(to: ~p"/")}
    end
  end
end
