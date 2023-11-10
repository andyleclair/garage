defmodule GarageWeb.BuildsLive.Show do
  use GarageWeb, :live_view

  alias Garage.Builds
  alias Garage.Builds.{Build, Comment}
  alias AshPhoenix.Form
  import GarageWeb.Components.Builds.Comment
  import GarageWeb.Components.Builds.LikeHeart

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"build" => slug}, _, socket) do
    build =
      Build.get_by_slug!(slug,
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
     |> assign(:images, build.image_urls)
     |> assign(:selected_image, List.first(build.image_urls))
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
  def handle_event("select-image", %{"index" => index}, socket) do
    {:noreply,
     assign(
       socket,
       :selected_image,
       Enum.at(socket.assigns.build.image_urls, String.to_integer(index))
     )}
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
