defmodule Garage.Workers.ImportImages do
  @moduledoc """
  Oban worker that downloads images from '77 Garage and uploads them to S3/R2.

  This worker is queued after a build is imported, allowing the build to be
  created immediately while images are processed in the background.
  """

  use Oban.Worker, queue: :imports, max_attempts: 3

  require Logger

  alias Garage.Builds.Image

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "build_id" => build_id,
          "image_urls" => image_urls,
          "username" => username,
          "build_name" => build_name
        }
      }) do
    Logger.info("Starting image import for build #{build_id} - #{length(image_urls)} images")

    results =
      image_urls
      |> Enum.with_index()
      |> Enum.map(fn {url, index} ->
        case download_and_upload(url, username, build_name) do
          {:ok, public_url} ->
            create_image_record(build_id, public_url, index)

          {:error, reason} ->
            Logger.error("Failed to import image #{url}: #{inspect(reason)}")
            {:error, reason}
        end
      end)

    successful = Enum.count(results, &match?({:ok, _}, &1))
    failed = Enum.count(results, &match?({:error, _}, &1))

    Logger.info(
      "Image import complete for build #{build_id}: #{successful} successful, #{failed} failed"
    )

    if failed > 0 and successful == 0 do
      # All failed - retry the job
      {:error, "All image imports failed"}
    else
      # At least some succeeded
      :ok
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
    # Try to get content type from headers
    content_type =
      Enum.find_value(headers, fn
        {"content-type", value} -> value
        _ -> nil
      end)

    # Fall back to extension-based detection
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
    # Sanitize build name for path
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

  defp create_image_record(build_id, original_url, index) do
    case Image.create(%{build_id: build_id, original_url: original_url, index: index}) do
      {:ok, image} ->
        # Queue resize job to create thumbnail and optimized versions
        %{"image_id" => image.id}
        |> Garage.Workers.Resize.new()
        |> Oban.insert!()

        {:ok, image}

      {:error, reason} ->
        Logger.error("Failed to create image record: #{inspect(reason)}")
        {:error, {:db_error, reason}}
    end
  end

  defp bucket, do: Application.get_env(:garage, :upload_bucket)

  defp public_url(key) do
    "#{Application.get_env(:garage, :public_image_root)}#{key}"
  end
end
