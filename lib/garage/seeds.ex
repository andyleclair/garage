defmodule Garage.Seeds do
  @moduledoc """
  Module to encapsulate seed logic
  """
  alias Garage.Mopeds

  def seeds do
    Path.join([:code.priv_dir(:garage), "repo", "makes_and_models.json"])
    |> File.read!()
    |> Jason.decode!()
    |> Enum.map(fn {make, models} ->
      models = for model <- models, into: MapSet.new(), do: %{name: model["model"]}
      %{name: make, models: MapSet.to_list(models)}
    end)
    |> Mopeds.bulk_create!(Garage.Mopeds.Make, :bulk_create,
      return_errors?: true,
      stop_on_error?: true
    )
  end
end
