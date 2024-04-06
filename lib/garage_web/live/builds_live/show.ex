defmodule GarageWeb.BuildsLive.Show do
  use GarageWeb, :live_view

  alias Garage.Builds.Build
  alias Garage.Builds.Comment
  alias AshPhoenix.Form

  import GarageWeb.Components.Builds.Comment
  import GarageWeb.Components.Builds.LikeHeart
  import GarageWeb.Components.Builds.FollowButton

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"build" => slug}, url, socket) do
    build = build(slug, socket.assigns.current_user)

    {:noreply,
     socket
     |> assign(:page_title, build.name)
     |> assign(:build, build)
     |> assign(:images, build.image_urls)
     |> assign(:selected_image, build.first_image)
     |> assign(:index, 0)
     |> assign(:meta, %{
       "og:url" => url,
       "og:image" => build.first_image,
       "og:description" => build.description,
       "og:title" => build.name
     })
     |> assign(
       :comment_form,
       to_form(Form.for_action(Comment, :create, actor: socket.assigns.current_user))
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
  def handle_event(
        "follow",
        _params,
        %{assigns: %{build: build, current_user: current_user}} = socket
      ) do
    # {:ok, _follow} = Build.follow(build, actor: current_user)
    build = %{
      build
      | followed_by_user: true
    }

    {:noreply, assign(socket, :build, build)}
  end

  def handle_event(
        "unfollow",
        _params,
        %{assigns: %{build: build, current_user: current_user}} = socket
      ) do
    # {:ok, _follow} = Build.unfollow(build, actor: current_user)
    build = %{
      build
      | followed_by_user: false
    }

    {:noreply, assign(socket, :build, build)}
  end

  @impl true
  def handle_event("select-image", %{"index" => index}, socket) do
    index = String.to_integer(index)

    {:noreply,
     socket
     |> assign(:selected_image, Enum.at(socket.assigns.build.image_urls, index))
     |> assign(:index, index)}
  end

  @impl true
  def handle_event(
        "next-image",
        _,
        %{assigns: %{index: index, images: images, build: build}} = socket
      ) do
    length = length(images)

    # wrap
    index =
      if index + 1 == length do
        0
      else
        index + 1
      end

    {:noreply,
     socket
     |> assign(:selected_image, Enum.at(build.image_urls, index))
     |> assign(:index, index)}
  end

  @impl true
  def handle_event(
        "prev-image",
        _,
        %{assigns: %{index: index, images: images, build: build}} = socket
      ) do
    length = length(images)

    # wrap
    index =
      if index - 1 == -1 do
        length - 1
      else
        index - 1
      end

    {:noreply,
     socket
     |> assign(:selected_image, Enum.at(build.image_urls, index))
     |> assign(:index, index)}
  end

  @impl true
  def handle_event("add_comment", %{"form" => params}, %{assigns: %{build: build}} = socket) do
    case Form.submit(socket.assigns.comment_form, params: params) do
      {:ok, comment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Comment added!")
         |> assign(
           :comment_form,
           to_form(Form.clear_value(socket.assigns.comment_form, :text))
           |> dbg
         )
         |> assign(:build, %{build | comments: build.comments ++ [comment]})}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  defp build(slug, current_user) when not is_nil(current_user) do
    Build.get_by_slug!(slug,
      load: [
        comments: [user: [:name]],
        likes: [user: [:name]],
        liked_by_user: %{user_id: current_user.id}
      ]
    )
  end

  defp build(slug, _) do
    Build.get_by_slug!(slug,
      load: [
        comments: [user: [:name]],
        likes: [user: [:name]]
      ]
    )
  end
end
