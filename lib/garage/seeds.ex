defmodule Garage.Seeds do
  @moduledoc """
  Module to encapsulate seed logic
  """
  alias Garage.Mopeds

  def seeds do
    manufacturers_and_models =
      Path.join([:code.priv_dir(:garage), "repo", "makes_and_models.json"])
      |> File.read!()
      |> Jason.decode!()
      |> Enum.map(fn {manufacturer, models} ->
        models = for model <- models, into: MapSet.new(), do: %{name: model["model"]}

        stock_parts =
          Enum.reduce(models, %{exhausts: [], forks: [], wheels: []}, fn %{name: model}, acc ->
            %{
              acc
              | exhausts: [%{name: "#{model} Stock Exhaust"} | acc.exhausts],
                forks: [%{name: "#{model} Stock Forks"} | acc.forks],
                wheels: [%{name: "#{model} Stock Wheels"} | acc.wheels]
            }
          end)

        %{
          name: manufacturer,
          models: MapSet.to_list(models),
          category: :moped,
          exhausts: stock_parts.exhausts,
          forks: stock_parts.forks,
          wheels: stock_parts.wheels
        }
      end)

    Mopeds.bulk_create!(manufacturers_and_models, Garage.Mopeds.Manufacturer, :bulk_create,
      return_errors?: true,
      stop_on_error?: true
    )
  end
end
