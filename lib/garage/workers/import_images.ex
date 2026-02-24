defmodule Garage.Workers.ImportImages do
  @moduledoc """
  Oban worker that downloads images from '77 Garage and uploads them to S3/R2.

  This worker processes images that were already created with original '77 Garage URLs.
  It downloads each image, uploads to S3, updates the record, and broadcasts via PubSub.
  """

  use Oban.Worker, queue: :imports, max_attempts: 3

  require Logger

  alias Garage.Builds.Image

  @pubsub Garage.PubSub

  @doc """
  Creates image records immediately with original URLs so they display right away.
  Returns the list of created images.
  """
  def create_placeholder_images(build_id, image_urls) do
    image_urls
    |> Enum.with_index()
    |> Enum.map(fn {url, index} ->
      case Image.create(%{build_id: build_id, original_url: url, index: index}) do
        {:ok, image} ->
          image

        {:error, reason} ->
          Logger.error("Failed to create placeholder image: #{inspect(reason)}")
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Broadcasts an image update to subscribers.
  """
  def broadcast_image_update(build_id, image) do
    Phoenix.PubSub.broadcast(@pubsub, "build:#{build_id}:images", {:image_updated, image})
  end

  @doc """
  Subscribe to image updates for a build.
  """
  def subscribe(build_id) do
    Phoenix.PubSub.subscribe(@pubsub, "build:#{build_id}:images")
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "build_id" => build_id,
          "image_ids" => image_ids,
          "username" => username,
          "build_name" => build_name
        }
      }) do
    Logger.info("Starting image import for build #{build_id} - #{length(image_ids)} images")

    results =
      image_ids
      |> Enum.map(fn image_id ->
        process_image(image_id, username, build_name, build_id)
      end)

    successful = Enum.count(results, &match?(:ok, &1))
    failed = Enum.count(results, &match?({:error, _}, &1))

    Logger.info(
      "Image import complete for build #{build_id}: #{successful} successful, #{failed} failed"
    )

    # Broadcast completion
    Phoenix.PubSub.broadcast(
      @pubsub,
      "build:#{build_id}:images",
      {:import_complete, successful, failed}
    )

    if failed > 0 and successful == 0 do
      {:error, "All image imports failed"}
    else
      :ok
    end
  end

  defp process_image(image_id, username, build_name, build_id) do
    case Image.get(image_id) do
      {:ok, image} ->
        source_url = image.original_url

        case download_and_upload(source_url, username, build_name) do
          {:ok, new_url} ->
            # Update the image record with the new S3 URL
            case Image.update(image, %{original_url: new_url}) do
              {:ok, updated_image} ->
                # Queue resize job
                %{"image_id" => updated_image.id}
                |> Garage.Workers.Resize.new()
                |> Oban.insert!()

                # Broadcast the update
                broadcast_image_update(build_id, updated_image)
                :ok

              {:error, reason} ->
                Logger.error("Failed to update image #{image_id}: #{inspect(reason)}")
                {:error, reason}
            end

          {:error, reason} ->
            Logger.error(
              "Failed to download/upload image #{image_id} from #{source_url}: #{inspect(reason)}"
            )

            {:error, reason}
        end

      {:error, reason} ->
        Logger.error("Failed to find image #{image_id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp download_and_upload(url, username, build_name) do
    with {:ok, body, content_type} <- download_image(url),
         key <- generate_key(username, build_name, url, content_type),
         :ok <- upload_to_s3(key, body, content_type) do
      {:ok, public_url(key)}
    end
  end

  defp download_image(url) do
    headers = [
      {"User-Agent", "MopedClub/1.0"},
      {"Accept", "image/*"}
    ]

    request = Finch.build(:get, url, headers)

    case Finch.request(request, Garage.Finch, receive_timeout: 30_000) do
      {:ok, %Finch.Response{status: 200, body: body, headers: headers}} ->
        content_type = get_content_type(headers, url)
        {:ok, body, content_type}

      {:ok, %Finch.Response{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, {:download_failed, reason}}
    end
  end

  defp get_content_type(headers, url) do
    content_type =
      Enum.find_value(headers, fn
        {"content-type", value} -> value
        _ -> nil
      end)

    if content_type && String.starts_with?(content_type, "image/") do
      content_type |> String.split(";") |> List.first()
    else
      extension = url |> URI.parse() |> Map.get(:path, "") |> Path.extname() |> String.downcase()

      case extension do
        ".jpg" -> "image/jpeg"
        ".jpeg" -> "image/jpeg"
        ".png" -> "image/png"
        ".webp" -> "image/webp"
        ".gif" -> "image/gif"
        _ -> "image/jpeg"
      end
    end
  end

  defp generate_key(username, build_name, _url, content_type) do
    safe_build_name =
      build_name
      |> String.replace(~r/[^\w\s-]/, "")
      |> String.replace(~r/\s+/, "_")
      |> String.slice(0, 50)

    extension = extension_for_content_type(content_type)
    uuid = Ash.UUID.generate()

    "/garage/users/#{username}/builds/#{safe_build_name}/imports/#{uuid}#{extension}"
  end

  defp extension_for_content_type("image/jpeg"), do: ".jpg"
  defp extension_for_content_type("image/png"), do: ".png"
  defp extension_for_content_type("image/webp"), do: ".webp"
  defp extension_for_content_type("image/gif"), do: ".gif"
  defp extension_for_content_type(_), do: ".jpg"

  defp upload_to_s3(key, body, content_type) do
    case ExAws.S3.put_object(bucket(), key, body, content_type: content_type)
         |> ExAws.request() do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, {:upload_failed, reason}}
    end
  end

  defp bucket, do: Application.get_env(:garage, :upload_bucket)

  defp public_url(key) do
    "#{Application.get_env(:garage, :public_image_root)}#{key}"
  end
end
