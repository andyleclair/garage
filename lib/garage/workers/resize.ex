defmodule Garage.Workers.Resize do
  use Oban.Worker, queue: :resize
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"image_id" => image_id} = _args}) do
    Logger.debug("Starting resize for image #{image_id}")
    image_record = Garage.Builds.Image.get!(image_id)
    parsed_uri = URI.parse(image_record.original_url)

    case ExAws.S3.get_object(bucket(), parsed_uri.path) |> ExAws.request() do
      {:ok, %{body: body}} ->
        {:ok, image} = Image.from_binary(body)
        {:ok, thumbnail} = Image.thumbnail(image, 400)
        bin = Image.write!(thumbnail, :memory, minimize_file_size: true, suffix: ".webp")

        optimized =
          Image.write!(image, :memory, minimize_file_size: true, suffix: ".webp", quality: 85)

        thumb_path = path(parsed_uri.path, "thumbnail")
        optimized_path = path(parsed_uri.path, "optimized")

        ExAws.S3.put_object(bucket(), thumb_path, bin) |> ExAws.request!()
        ExAws.S3.put_object(bucket(), optimized_path, optimized) |> ExAws.request!()

        Garage.Builds.Image.update!(image_record, %{
          thumbnail_url: URI.to_string(%URI{parsed_uri | path: thumb_path}),
          optimized_url: URI.to_string(%URI{parsed_uri | path: optimized_path})
        })

        :ok

      {:error, error} ->
        Logger.error("Failed to fetch image from S3: #{inspect(error)}")
        {:cancel, "Missing source image"}
    end
  end

  defp path(original_path, new_suffix) do
    {original_name, path} = original_path |> Path.split() |> List.pop_at(-1)
    uuid = String.slice(original_name, 0..35)
    new_name = IO.iodata_to_binary([uuid, ~c"-", new_suffix, file_format()])
    path |> Kernel.++([new_name]) |> Path.join()
  end

  defp bucket, do: Application.get_env(:garage, :upload_bucket)

  defp file_format, do: ".webp"
end
