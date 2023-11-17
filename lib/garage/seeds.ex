defmodule Garage.Seeds do
  @moduledoc """
  Module to encapsulate seed logic
  """
  alias Garage.Mopeds

  def seeds do
    makes_and_models =
      Path.join([:code.priv_dir(:garage), "repo", "makes_and_models.json"])
      |> File.read!()
      |> Jason.decode!()
      |> Enum.map(fn {make, models} ->
        models = for model <- models, into: MapSet.new(), do: %{name: model["model"]}
        %{name: make, models: MapSet.to_list(models)}
      end)

    Mopeds.bulk_create!(makes_and_models, Garage.Mopeds.Make, :bulk_create,
      return_errors?: true,
      stop_on_error?: true
    )

    Enum.each(makes_and_models, fn %{name: make, models: models} ->
      Enum.each(models, fn %{name: model} ->
        Mopeds.create(
          Ash.Changeset.new(Mopeds.Ignition, %{
            name: "#{model} Stock Ignition",
            manufacturer: make
          })
        )

        Mopeds.create(
          Ash.Changeset.new(Mopeds.Exhaust, %{
            name: "#{model} Stock Exhaust",
            manufacturer: make
          })
        )

        Mopeds.create(
          Ash.Changeset.new(Mopeds.Crank, %{
            name: "#{model} Stock Crank",
            manufacturer: make
          })
        )

        Mopeds.create(
          Ash.Changeset.new(Mopeds.Forks, %{
            name: "#{model} Stock Forks",
            manufacturer: make
          })
        )

        Mopeds.create(
          Ash.Changeset.new(Mopeds.Wheels, %{
            name: "#{model} Stock Wheels",
            manufacturer: make
          })
        )
      end)
    end)
  end
end
