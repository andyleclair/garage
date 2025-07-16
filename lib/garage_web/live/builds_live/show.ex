defmodule GarageWeb.BuildsLive.Show do
  use GarageWeb, :live_view

  import GarageWeb.Components.Builds.Comment
  import GarageWeb.Components.Builds.FollowButton
  import GarageWeb.Components.Builds.LikeHeart

  alias AshPhoenix.Form
  alias Garage.Builds.Build
  alias Garage.Builds.Comment

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
     |> assign(:thumbnails, thumbnails(build))
     |> assign(:selected_image, selected_image(build, 0))
     |> assign(:index, 0)
     |> assign(:meta, %{
       "og:url" => url,
       "og:image" => first_image_url(build),
       "og:description" => build.description,
       "og:title" => build.name
     })
     |> assign(
       :comment_form,
       to_form(Form.for_action(Comment, :create, actor: socket.assigns.current_user))
     )
     |> assign(:can_edit?, Build.can_update?(socket.assigns.current_user, build))}
  end

  defp first_image_url(build) do
    if is_list(build.images) and not Enum.empty?(build.images) do
      img = Enum.at(build.images, 0)
      if img.thumbnail_url, do: img.thumbnail_url, else: img.original_url
    else
      Enum.at(build.image_urls, 0)
    end
  end

  defp selected_image(build, index) do
    if is_list(build.images) and not Enum.empty?(build.images) do
      Enum.at(build.images, index)
    else
      Enum.at(build.image_urls, index)
    end
  end

  defp thumbnails(build) do
    if is_list(build.images) and not Enum.empty?(build.images) do
      Enum.map(build.images, fn img ->
        if img.thumbnail_url, do: img.thumbnail_url, else: img.original_url
      end)
    else
      build.image_urls
    end
  end

  @impl true
  def handle_event("login", _, socket) do
    {:noreply,
     socket |> put_flash(:error, "You Must Be Logged In First!") |> redirect(to: ~p"/sign-in")}
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
    {:ok, _follow} = Build.follow(build, actor: current_user)

    build = %{
      build
      | followed_by_user: true,
        follows: [%{user: current_user, user_id: current_user.id} | build.follows]
    }

    {:noreply, assign(socket, :build, build)}
  end

  def handle_event(
        "unfollow",
        _params,
        %{assigns: %{build: build, current_user: current_user}} = socket
      ) do
    {:ok, _follow} = Build.unfollow(build, actor: current_user)

    build = %{
      build
      | followed_by_user: false,
        follows: Enum.reject(build.follows, fn follow -> follow.user_id == current_user.id end)
    }

    {:noreply, assign(socket, :build, build)}
  end

  @impl true
  def handle_event("select-image", %{"index" => index}, socket) do
    index = String.to_integer(index)

    selected_image = selected_image(socket.assigns.build, index)

    {:noreply,
     socket
     |> assign(:selected_image, selected_image)
     |> assign(:index, index)}
  end

  @impl true
  def handle_event("add_comment", %{"form" => params}, %{assigns: %{build: build}} = socket) do
    case Form.submit(socket.assigns.comment_form, params: params) do
      {:ok, comment} ->
        form =
          Form.for_action(Comment, :create, actor: socket.assigns.current_user)

        {:noreply,
         socket
         |> put_flash(:info, "Comment added!")
         |> assign(:comment_form, to_form(form))
         |> assign(:build, %{build | comments: build.comments ++ [comment]})}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  @impl true
  def handle_event(
        "validate_comment",
        %{"form" => params},
        %{assigns: %{comment_form: form}} = socket
      ) do
    form = Form.validate(form, params)
    {:noreply, assign(socket, :comment_form, form)}
  end

  defp build(slug, current_user) when not is_nil(current_user) do
    Build.get_by_slug!(slug,
      load: [
        comments: [user: [:name]],
        likes: [user: [:name]],
        follows: [user: [:name]],
        liked_by_user: %{user_id: current_user.id},
        followed_by_user: %{user_id: current_user.id}
      ]
    )
  end

  defp build(slug, _) do
    Build.get_by_slug!(slug,
      load: [
        comments: [user: [:name]],
        likes: [user: [:name]],
        follows: [user: [:name]]
      ]
    )
  end
end
