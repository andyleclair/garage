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

  # 0 ?
  # 1 engines'
  # 2 carburetors
  # 3 cylinders 
  # 4 exhausts
  # 5 ignitions 
  # 6 cranks 
  # 7 clutches 
  #
  # desired state: 
  # %{"manufacturer name" => %{engines: [...], carburetors: [...] ...} }
  #
  def generate_carb_seeds() do
    mapping = %{
      "1" => :engines,
      "2" => :carburetors,
      "3" => :cylinders,
      "4" => :exhausts,
      "5" => :ignitions,
      "6" => :cranks,
      "7" => :clutches
    }

    json =
      File.read!(Path.join([:code.priv_dir(:garage), "repo", "1977dump.json"])) |> Jason.decode!()

    parts_by_manufacturer =
      Enum.reduce(json, %{}, fn {idx, records}, acc ->
        parts_by_manufacturer =
          Enum.reduce(records, %{}, fn %{"name" => name}, parts_by_manufacturer ->
            [manufacturer, name] = String.split(name, " ", parts: 2)

            Map.update(parts_by_manufacturer, manufacturer, [name], fn names -> [name | names] end)
          end)

        part_type = mapping[idx]

        Enum.reduce(parts_by_manufacturer, acc, fn {manufacturer_name, parts}, inner_acc ->
          Map.update(inner_acc, manufacturer_name, %{part_type => parts}, fn manufacturer_rec ->
            Map.put(manufacturer_rec, part_type, parts)
          end)
        end)
      end)

    Enum.each(parts_by_manufacturer, fn {name, parts} ->
      path = Path.join([:code.priv_dir(:garage), "repo", "seeds", "#{name}.json"])

      content =
        if File.exists?(path) do
          path
          |> File.read!()
          |> Jason.decode!()
          |> Map.merge(%{
            engines: Map.get(parts, :engines, []),
            carburetors: Map.get(parts, :carburetors, [])
          })
          |> then(fn rec ->
            Map.put(rec, :categories, record_to_categories(rec))
          end)
        else
          %{
            name: name,
            engines: Map.get(parts, :engines, []),
            carburetors: Map.get(parts, :carburetors, []),
            categories: record_to_categories(parts)
          }
        end
        |> Jason.encode!()
        |> Jason.Formatter.pretty_print()

      File.write!(path, content)
    end)
  end

  defp record_to_categories(rec) do
    for {part, parts} when parts != [] <- rec do
      part
    end
  end
end
