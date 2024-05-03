defmodule Garage.Imports.Garage do
  @moduledoc """
  Imports builds from 1977 Mopeds Garage
  https://garage.1977mopeds.com
  """

  def import_build(url) do
    # Import build from 1977 Mopeds Garage
    case get_build(url) do
      {:ok, build} ->
        # Save build to local database
        Garage.Builds.Build.create(%{
          name: build.name,
          description: build.description
        })

      {:error, _} ->
        IO.puts("Failed to import build")
    end
  end

  def get_build(url) do
    case Finch.build(:get, url)
         |> Finch.request(Garage.Finch) do
      {:ok, %Finch.Response{status_code: 200, body: body}} ->
        {:ok, parse_build(body)}

      {:ok, %Finch.Response{status_code: 404}} ->
        {:error, :not_found}

      {:error, reason} ->
        Logger.debug("Failed to fetch build: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def parse_build(html) do
    {:ok, document} = Floki.parse_document(html)

    name =
      Floki.find(document, ".g-module h1")
      |> Floki.text()

    description =
      Floki.find(document, ".g-module .build-description p")
      |> Floki.text()

    [_, _, _, _, _, _, year, make, model] =
      document
      |> Floki.find(".g-build-detail-category")
      |> List.first()
      |> Floki.text()
      |> String.split(~r/\W/, parts: 9)

    images =
      document
      |> Floki.find("ul.slides img")
      |> Floki.attribute("src")
      |> Enum.map(fn path -> "https://garage.1977mopeds.com#{path}" end)

    %{
      name: name,
      description: description,
      year: year,
      image_urls: images
    }
  end
end
