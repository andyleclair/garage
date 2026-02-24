defmodule Garage.Seeds do
  @moduledoc """
  Module to encapsulate seed logic
  """
  alias Garage.Mopeds.Manufacturer

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
      |> Ash.create!()
    end)
  end

  # Run me first
  def generate_make_and_model_seeds do
    Path.join([:code.priv_dir(:garage), "repo", "makes_and_models.json"])
    |> File.read!()
    |> Jason.decode!()
    |> Enum.map(fn {manufacturer, models} ->
      outfile = File.open!("priv/repo/seeds/#{manufacturer}.json", [:write, :utf8])

      models = for model <- models, into: MapSet.new(), do: %{name: model["model"]}

      stock_parts =
        Enum.reduce(
          models,
          %{exhausts: []},
          fn %{name: model}, acc ->
            %{acc | exhausts: [%{name: "#{model} Stock Exhaust"} | acc.exhausts]}
          end
        )

      data =
        %{
          name: manufacturer,
          models: MapSet.to_list(models),
          engines: [],
          clutches: [],
          cranks: [],
          ignitions: [],
          pulleys: [],
          variators: [],
          categories: [:mopeds],
          exhausts: stock_parts.exhausts,
          cylinders: []
        }
        |> Jason.encode!()
        |> Jason.Formatter.pretty_print()

      IO.write(outfile, data)
      File.close(outfile)
    end)
  end

  # Run me next
  def generate_part_seeds() do
    mapping = %{
      "1" => :engines,
      "2" => :carburetors,
      "3" => :cylinders,
      "4" => :exhausts,
      "5" => :ignitions,
      "6" => :cranks,
      "7" => :clutches,
      "8" => :variators,
      "9" => :pulleys
    }

    json =
      File.read!(Path.join([:code.priv_dir(:garage), "repo", "input.json"])) |> Jason.decode!()

    parts_by_manufacturer =
      Enum.reduce(json, %{}, fn {idx, records}, acc ->
        part_type = mapping[idx]

        parts_by_manufacturer =
          Enum.reduce(records, %{}, fn %{"name" => original_name} = part, parts_by_manufacturer ->
            {manufacturer, item} =
              case part_type do
                :engines ->
                  if String.starts_with?(original_name, "Franco Morini") do
                    # spesh case for the special pipes
                    name =
                      String.split(original_name, " ")
                      |> then(fn list -> Enum.slice(list, 2..length(list)) end)
                      |> Enum.join(" ")

                    {"Franco Morini", %{"name" => name}}
                  else
                    [manufacturer, name] = String.split(original_name, " ", parts: 2)

                    {manufacturer, %{"name" => name}}
                  end

                :cylinders ->
                  # i made sure the real manufacturer is last
                  {real_manufacturer, rest} = String.split(original_name, " ") |> List.pop_at(-1)
                  name = Enum.join(rest, " ")

                  displacement =
                    Enum.find(rest, fn i -> String.ends_with?(i, "cc") end)
                    |> then(fn str ->
                      Regex.run(~r/\d\d/, str) |> List.first() |> String.to_integer()
                    end)

                  {real_manufacturer, %{"name" => name, "displacement" => displacement}}

                :exhausts ->
                  if String.starts_with?(original_name, "EV Racing") do
                    # spesh case for the special pipes
                    name =
                      String.split(original_name, " ")
                      |> then(fn list -> Enum.slice(list, 2..length(list)) end)
                      |> Enum.join(" ")

                    {"EV Racing", %{"name" => name}}
                  else
                    [manufacturer, name] = String.split(original_name, " ", parts: 2)
                    {manufacturer, %{"name" => name}}
                  end

                :carburetors ->
                  Map.pop(part, "manufacturer")

                :variators ->
                  [manufacturer, name] = String.split(original_name, " ", parts: 2)

                  {manufacturer,
                   %{
                     "name" => name,
                     "type" => part["type"],
                     "rollers" => part["rollers"],
                     "size" => part["size"]
                   }}

                :pulleys ->
                  [manufacturer, name] = String.split(original_name, " ", parts: 2)

                  {manufacturer,
                   %{
                     "name" => name,
                     "sizes" => part["sizes"]
                   }}

                _ ->
                  [manufacturer, name] = String.split(original_name, " ", parts: 2)
                  {manufacturer, %{"name" => name}}
              end

            Map.update(parts_by_manufacturer, manufacturer, [item], fn items -> [item | items] end)
          end)

        Enum.reduce(parts_by_manufacturer, acc, fn {manufacturer_name, parts}, inner_acc ->
          Map.update(inner_acc, manufacturer_name, %{part_type => parts}, fn manufacturer_rec ->
            Map.put(manufacturer_rec, part_type, parts)
          end)
        end)
      end)

    Enum.each(parts_by_manufacturer, fn {name, parts} ->
      path = Path.join([:code.priv_dir(:garage), "repo", "seeds", "#{name}.json"])

      cranks =
        Map.get(parts, :engines, [])
        |> Enum.map(fn %{"name" => name} -> %{"name" => "#{name} Stock Crank"} end)

      stock_ignitions =
        Map.get(parts, :engines, [])
        |> Enum.map(fn %{"name" => name} -> %{"name" => "#{name} Stock Ignition"} end)

      ignitions = (stock_ignitions ++ Map.get(parts, :ignitions, [])) |> Enum.uniq()

      content =
        if File.exists?(path) do
          path
          |> File.read!()
          |> Jason.decode!()
          |> Map.merge(%{
            "engines" => Map.get(parts, :engines, []),
            "carburetors" => Map.get(parts, :carburetors, []),
            "cranks" => cranks,
            "exhausts" => Map.get(parts, :exhausts, []),
            "cylinders" => Map.get(parts, :cylinders, []),
            "clutches" => Map.get(parts, :clutches, []),
            "ignitions" => ignitions,
            "pulleys" => Map.get(parts, :pulleys, []),
            "variators" => Map.get(parts, :variators, [])
          })
          |> then(fn rec ->
            Map.put(rec, "categories", record_to_categories(rec))
          end)
        else
          %{
            "name" => name,
            "engines" => Map.get(parts, :engines, []),
            "cranks" => cranks,
            "carburetors" => Map.get(parts, :carburetors, []),
            "exhausts" => Map.get(parts, :exhausts, []),
            "cylinders" => Map.get(parts, :cylinders, []),
            "clutches" => Map.get(parts, :clutches, []),
            "ignitions" => ignitions,
            "variators" => Map.get(parts, :variators, []),
            "pulleys" => Map.get(parts, :pulleys, []),
            "categories" => record_to_categories(parts)
          }
        end
        |> Jason.encode!()
        |> Jason.Formatter.pretty_print()

      File.write!(path, content)
    end)
  end

  defp record_to_categories(rec) do
    for {part, parts} when parts != [] and part not in ~w(name categories) <- rec do
      if part in [:models, "models"], do: :mopeds, else: part
    end
  end

  @doc """
  Generates stock clutches for manufacturers that have engines but no clutches.

  This reads all seed JSON files, and for each manufacturer that has engines
  but an empty clutches array, it generates stock clutches based on the engine names.

  Run with: Garage.Seeds.generate_stock_clutches()
  """
  def generate_stock_clutches do
    seeds_dir = Path.join([:code.priv_dir(:garage), "repo", "seeds"])

    Path.join(seeds_dir, "*.json")
    |> Path.wildcard()
    |> Enum.each(fn path ->
      content = File.read!(path) |> Jason.decode!()

      engines = Map.get(content, "engines", [])
      clutches = Map.get(content, "clutches", [])

      # Only generate if there are engines but no clutches
      if engines != [] and clutches == [] do
        manufacturer_name = Map.get(content, "name", Path.basename(path, ".json"))

        # Generate stock clutches from engines
        stock_clutches =
          engines
          |> Enum.map(fn %{"name" => name} -> %{"name" => "#{name} Stock Clutch"} end)
          |> Enum.uniq()

        IO.puts("Adding #{length(stock_clutches)} stock clutches for #{manufacturer_name}")

        updated_content =
          content
          |> Map.put("clutches", stock_clutches)
          |> update_categories_if_needed()
          |> Jason.encode!()
          |> Jason.Formatter.pretty_print()

        File.write!(path, updated_content)
      end
    end)

    IO.puts("\nDone! Run `mix run priv/repo/seeds.exs` to reload seeds.")
  end

  # Ensure "clutches" is in categories if clutches were added
  defp update_categories_if_needed(content) do
    categories = Map.get(content, "categories", [])
    clutches = Map.get(content, "clutches", [])

    if clutches != [] and "clutches" not in categories and :clutches not in categories do
      Map.put(content, "categories", ["clutches" | categories])
    else
      content
    end
  end

  @doc """
  Adds missing stock clutches directly to the database for existing manufacturers.

  For each manufacturer with engines but no clutches, this creates stock clutches
  named "{engine_name} Stock Clutch".

  Run with: Garage.Seeds.add_missing_stock_clutches()
  """
  def add_missing_stock_clutches do
    require Ash.Query
    alias Garage.Mopeds.{Manufacturer, Engine, Clutch}

    # Get all manufacturers
    manufacturers = Manufacturer.read_all!()

    Enum.each(manufacturers, fn manufacturer ->
      mfr_id = manufacturer.id

      # Get engines for this manufacturer
      engines =
        Engine
        |> Ash.Query.filter(manufacturer_id == ^mfr_id)
        |> Ash.read!()

      # Get existing clutches for this manufacturer
      existing_clutches =
        Clutch
        |> Ash.Query.filter(manufacturer_id == ^mfr_id)
        |> Ash.read!()

      existing_clutch_names = MapSet.new(existing_clutches, & &1.name)

      # Generate stock clutch names from engines
      stock_clutch_names =
        engines
        |> Enum.map(fn engine -> "#{engine.name} Stock Clutch" end)
        |> Enum.reject(fn name -> MapSet.member?(existing_clutch_names, name) end)

      if stock_clutch_names != [] do
        IO.puts("Adding #{length(stock_clutch_names)} clutches for #{manufacturer.name}")

        Enum.each(stock_clutch_names, fn name ->
          changeset =
            Ash.Changeset.for_create(Clutch, :create, %{name: name, manufacturer_id: mfr_id})

          case Ash.create(changeset) do
            {:ok, _clutch} ->
              IO.puts("  Created: #{name}")

            {:error, error} ->
              IO.puts("  Failed to create #{name}: #{inspect(error)}")
          end
        end)
      end
    end)

    IO.puts("\nDone!")
  end
end
