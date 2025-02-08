defmodule Garage.Notifiers.Push do
  use Ash.Notifier

  alias Ash.Notifier.Notification
  alias Garage.Builds.Comment

  # Send a push to the builder when their build gets liked
  def notify(%Notification{action: %{name: :like}, data: data, actor: user}) do
    builder_id = data.builder.id

    message =
      Jason.encode!(%{
        message: "#{user.username} just liked your build #{data.name}!",
        url: ~s{/builds/#{data.slug}}
      })

    %{"builder_id" => builder_id, "message" => message}
    |> Garage.Workers.Push.new()
    |> Oban.insert!()

    :ok
  end

  # Comments don't load the full build so we pass the build id (instead of builder) to push
  def notify(%Notification{resource: Comment, action: %{name: :create}, data: data, actor: user}) do
    dbg(data)
    title = "#{user.username} just commented on your build!"

    message =
      Jason.encode!(%{
        title: title,
        message: data.text
      })

    build_id = data.build_id

    %{"build_id" => build_id, "message" => message}
    |> Garage.Workers.Push.new()
    |> Oban.insert!()

    :ok
  end
end
