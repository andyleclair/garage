defmodule Garage.Seeds do
  @moduledoc """
  Module to encapsulate seed logic
  """
  alias Garage.Mopeds.Manufacturer
  alias Garage.Mopeds

  def seeds do
    [:code.priv_dir(:garage), "repo", "seeds", "*.json"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.map(fn path ->
      IO.puts("Reading path #{path}")

      json =
        path
        |> File.read!()
        |> Jason.decode!()

      Ash.Changeset.for_action(Manufacturer, :bulk_create, json)
      |> Mopeds.create!()
    end)
  end

  def generate_seeds do
    Path.join([:code.priv_dir(:garage), "repo", "makes_and_models.json"])
    |> File.read!()
    |> Jason.decode!()
    |> Enum.map(fn {manufacturer, models} ->
      outfile = File.open!("priv/repo/seeds/#{manufacturer}.json", [:write, :utf8])

      models = for model <- models, into: MapSet.new(), do: %{name: model["model"]}

      stock_parts =
        Enum.reduce(
          models,
          %{
            exhausts: [],
            forks: [],
            wheels: [],
            cylinders: []
          },
          fn %{
               name: model
             },
             acc ->
            %{
              acc
              | exhausts: [%{name: "#{model} Stock Exhaust"} | acc.exhausts],
                forks: [%{name: "#{model} Stock Forks"} | acc.forks],
                wheels: [%{name: "#{model} Stock Wheels"} | acc.wheels],
                cylinders: [%{name: "#{model} Stock Cylinder"} | acc.cylinders]
            }
          end
        )

      data =
        %{
          name: manufacturer,
          models: MapSet.to_list(models),
          engines: [],
          clutches: [
            %{name: "Stock Clutch"}
          ],
          cranks: [
            %{name: "Stock Crank"}
          ],
          ignitions: [
            %{name: "Stock Ignition"}
          ],
          pulleys: [],
          variators: [],
          categories: [:moped],
          exhausts: stock_parts.exhausts,
          forks: stock_parts.forks,
          wheels: stock_parts.wheels,
          cylinders: stock_parts.cylinders
        }
        |> Jason.encode!()
        |> Jason.Formatter.pretty_print()

      IO.write(outfile, data)
      File.close(outfile)
    end)
  end
end
