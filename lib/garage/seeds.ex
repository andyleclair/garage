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
            "ignitions" => Map.get(parts, :ignitions, []),
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
            "ignitions" => Map.get(parts, :ignitions, []),
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
end
