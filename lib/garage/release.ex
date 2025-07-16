defmodule Garage.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """

  @app :garage

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def seed do
    Garage.Seeds.seeds()
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  def move_image_urls_to_images do
    all_builds = Ash.read!(Garage.Builds.Build)

    for build <- all_builds do
      image_urls = build.image_urls

      image_urls
      |> Enum.with_index()
      |> Enum.each(fn {url, index} ->
        Ash.Changeset.for_create(
          Garage.Builds.Image,
          :create,
          %{
            build_id: build.id,
            original_url: url,
            index: index
          }
        )
        |> Ash.create!()
      end)
    end
  end

  def create_resize_jobs do
    all_builds = Ash.read!(Garage.Builds.Build)

    for build <- all_builds do
      for %{id: image_id} <- build.images do
        %{"image_id" => image_id}
        |> Garage.Workers.Resize.new()
        |> Oban.insert!()
      end
    end
  end
end
