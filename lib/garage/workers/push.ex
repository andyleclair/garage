defmodule Garage.Workers.Push do
  use Oban.Worker, queue: :push
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"builder_id" => builder_id, "message" => message}}) do
    Logger.debug("Starting push notification to user #{builder_id}")

    builder = Garage.Accounts.User.get_by_id!(builder_id, load: [:push_tokens])

    rejected_tokens =
      Enum.reduce(builder.push_tokens, [], fn token, acc ->
        case Garage.Push.send_notification(token, message) do
          {:ok, %Finch.Response{status: status}} when status in 200..299 ->
            acc

          {:ok, %Finch.Response{status: status} = resp} when status in 300..399 ->
            dbg(resp)
            acc

          {:ok, _resp} ->
            Logger.debug("Failed to send push to token #{token.id}")
            [token | acc]

          {:error, _} ->
            Logger.debug("Failed to send push to token #{token.id}")
            [token | acc]
        end
      end)

    Ash.bulk_destroy!(rejected_tokens, :destroy, %{})

    :ok
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"build_id" => build_id, "message" => message}}) do
    # lil hack here
    msg = Jason.decode!(message)
    Logger.debug("Getting builder for build #{build_id}")
    build = Garage.Builds.Build.get_by_id!(build_id, load: [builder: [:push_tokens]])
    builder = build.builder
    msg = Map.put(msg, "url", ~s{/builds/#{build.slug}})
    message = Jason.encode!(msg)
    Logger.debug("Starting push notification to user #{builder.id}")

    rejected_tokens =
      Enum.reduce(builder.push_tokens, [], fn token, acc ->
        case Garage.Push.send_notification(token, message) do
          {:ok, %Finch.Response{status: status}} when status in 200..299 ->
            acc

          {:ok, %Finch.Response{status: status} = resp} when status in 300..399 ->
            dbg(resp)
            acc

          {:ok, _resp} ->
            Logger.debug("Failed to send push to token #{token.id}")
            [token | acc]

          {:error, _} ->
            Logger.debug("Failed to send push to token #{token.id}")
            [token | acc]
        end
      end)

    Ash.bulk_destroy!(rejected_tokens, :destroy, %{})

    :ok
  end
end
