defmodule GarageWeb.BuildsLive.Show do
  use GarageWeb, :live_view

  alias Garage.Builds
  alias Garage.Builds.{Build, Comment}
  alias AshPhoenix.Form
  import GarageWeb.Components.Builds.Comment

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"build_id" => id}, _, socket) do
    build =
      Build.get_by_id!(id,
        load: [
          comments: [user: [:name]],
          likes: [user: [:name]],
          liked_by_user: %{user_id: socket.assigns.current_user.id}
        ]
      )

    {:noreply,
     socket
     |> assign(:page_title, build.name)
     |> assign(:build, build)
     |> assign(
       :comment_form,
       to_form(
         Form.for_action(
           Comment,
           :create,
           api: Builds,
           actor: socket.assigns.current_user
         )
       )
     )
     |> assign(:can_edit?, Build.can_update?(socket.assigns.current_user, build))}
  end

  @impl true
  def handle_event(
        "like",
        _params,
        %{assigns: %{build: build, current_user: current_user}} = socket
      ) do
    {:ok, _build} = Build.like(build, actor: current_user)

    build = %{
      build
      | liked_by_user: true,
        likes: [%{user: current_user, user_id: current_user.id} | build.likes]
    }

    {:noreply, assign(socket, :build, build)}
  end

  @impl true
  def handle_event(
        "dislike",
        _params,
        %{assigns: %{build: build, current_user: current_user}} = socket
      ) do
    {:ok, _build} = Build.dislike(build, actor: current_user)

    build = %{
      build
      | liked_by_user: false,
        likes: Enum.reject(build.likes, fn like -> like.user_id == current_user.id end)
    }

    {:noreply, assign(socket, :build, build)}
  end

  @impl true
  def handle_event("add_comment", %{"form" => params}, %{assigns: %{build: build}} = socket) do
    case Form.submit(socket.assigns.comment_form, params: params) do
      {:ok, comment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Comment added!")
         |> assign(:build, %{build | comments: build.comments ++ [comment]})}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
