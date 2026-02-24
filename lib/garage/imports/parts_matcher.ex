defmodule Garage.Imports.PartsMatcher do
  @moduledoc """
  Matches imported part names from '77 Garage to existing database records
  using PostgreSQL queries with fuzzy matching.

  '77 Garage part names often include the manufacturer prefix (e.g., "Dellorto 19mm PHBG"),
  while in our database the manufacturer is stored separately. This module handles
  searching across both the manufacturer name and part name.

  Special handling for "stock" parts: When a part name contains "stock", we look for
  stock parts that match the moped's manufacturer and model (e.g., "Peugeot Stock" on
  a Peugeot 103SP should match "Peugeot 103SP Stock Crank").
  """

  require Ash.Query

  alias Garage.Mopeds.{Carburetor, Clutch, Crank, Cylinder, Engine, Exhaust, Ignition}

  @doc """
  Attempts to match all parts from an import preview.

  Takes a parts map from `Garage.Imports.Garage.parse_build/1` and returns
  a map of `{part_type, {:ok, part} | {:error, :not_found}}`.

  The optional `context` map can include:
  - `:manufacturer_name` - The moped manufacturer (e.g., "Peugeot")
  - `:model_name` - The moped model (e.g., "103SP")

  These are used to better match "stock" parts.

  ## Example

      iex> match_all(%{cylinder: "Peugeot 50cc Airsal"}, %{manufacturer_name: "Peugeot", model_name: "103SP"})
      %{
        cylinder: {:ok, %Cylinder{...}}
      }
  """
  def match_all(parts, context \\ %{}) when is_map(parts) do
    parts
    |> Enum.map(fn {part_type, part_info} ->
      part_name = extract_part_name(part_info)
      {part_type, match_part(part_name, part_type, context)}
    end)
    |> Map.new()
  end

  defp extract_part_name(%{name: name}), do: name
  defp extract_part_name(name) when is_binary(name), do: name
  defp extract_part_name(_), do: nil

  @doc """
  Attempts to match a single part name to a database record.

  The search strategy handles the fact that '77 Garage names like "Dellorto 19mm PHBG"
  need to match our database where manufacturer="Dellorto" and name="PHBG".

  Special handling for "stock" parts: When the part name contains "stock", we prioritize
  parts that:
  1. Have "stock" in their name
  2. Match the moped's manufacturer (from context)
  3. Match the moped's model (from context)

  Returns `{:ok, part}` if found, `{:error, :not_found}` otherwise.
  """
  def match_part(part_name, part_type, context \\ %{})

  def match_part(nil, _part_type, _context), do: {:error, :not_found}

  def match_part(part_name, part_type, context) when is_binary(part_name) do
    resource = resource_for_type(part_type)

    if resource do
      normalized = normalize(part_name)

      # Load all parts with manufacturers and find best match in memory
      # This is more accurate than trying to do fuzzy matching in SQL
      case Ash.read(resource, load: [:manufacturer]) do
        {:ok, parts} when parts != [] ->
          find_best_match(parts, normalized, context)

        _ ->
          {:error, :not_found}
      end
    else
      {:error, :not_found}
    end
  end

  def match_part(_, _, _), do: {:error, :not_found}

  # Find the best matching part from a list using various strategies
  defp find_best_match(parts, search_name, context) do
    search_lower = String.downcase(search_name)
    search_words = extract_words(search_lower)
    is_stock_search = String.contains?(search_lower, "stock")

    # Extract context for stock matching
    moped_manufacturer =
      Map.get(context, :manufacturer_name, "") |> to_string() |> String.downcase()

    moped_model = Map.get(context, :model_name, "") |> to_string() |> String.downcase()

    # Score each part
    scored_parts =
      parts
      |> Enum.map(fn part ->
        full_name = build_full_name(part)
        full_name_lower = String.downcase(full_name)
        part_name_lower = String.downcase(part.name)

        base_score =
          calculate_match_score(search_lower, search_words, full_name_lower, part_name_lower)

        # Apply stock bonus if this is a stock search
        stock_bonus =
          if is_stock_search do
            calculate_stock_bonus(
              part,
              part_name_lower,
              full_name_lower,
              moped_manufacturer,
              moped_model
            )
          else
            0
          end

        {part, base_score + stock_bonus}
      end)
      |> Enum.filter(fn {_part, score} -> score > 0 end)
      |> Enum.sort_by(fn {_part, score} -> score end, :desc)

    case scored_parts do
      [{part, score} | _] when score >= 0.3 -> {:ok, part}
      _ -> {:error, :not_found}
    end
  end

  # Calculate bonus score for stock parts when searching for "stock"
  defp calculate_stock_bonus(
         part,
         part_name_lower,
         full_name_lower,
         moped_manufacturer,
         moped_model
       ) do
    has_stock_in_name = String.contains?(part_name_lower, "stock")

    # Check if part's manufacturer matches the moped manufacturer
    part_manufacturer_lower =
      if part.manufacturer, do: String.downcase(part.manufacturer.name), else: ""

    manufacturer_match =
      moped_manufacturer != "" and
        (part_manufacturer_lower == moped_manufacturer or
           String.contains?(full_name_lower, moped_manufacturer))

    # Check if part name contains the moped model
    model_match =
      moped_model != "" and String.contains?(full_name_lower, moped_model)

    cond do
      # Perfect stock match: has "stock", matches manufacturer and model
      has_stock_in_name and manufacturer_match and model_match -> 0.5
      # Good stock match: has "stock" and matches manufacturer
      has_stock_in_name and manufacturer_match -> 0.35
      # Partial stock match: has "stock" in name
      has_stock_in_name -> 0.2
      # Part matches manufacturer but doesn't have "stock" in name
      manufacturer_match -> 0.1
      true -> 0
    end
  end

  defp build_full_name(part) do
    if part.manufacturer do
      "#{part.manufacturer.name} #{part.name}"
    else
      part.name
    end
  end

  defp calculate_match_score(search_lower, search_words, full_name_lower, part_name_lower) do
    scores = [
      # Exact match on full name (manufacturer + part name)
      if(full_name_lower == search_lower, do: 1.0, else: 0),
      # Exact match on part name only
      if(part_name_lower == search_lower, do: 0.9, else: 0),
      # Full name contains entire search string
      if(String.contains?(full_name_lower, search_lower), do: 0.8, else: 0),
      # Search string contains entire full name
      if(String.contains?(search_lower, full_name_lower), do: 0.75, else: 0),
      # Part name is contained in search string
      if(String.contains?(search_lower, part_name_lower) and String.length(part_name_lower) > 2,
        do: 0.7,
        else: 0
      ),
      # Word-based similarity (Jaccard index)
      word_similarity(search_words, full_name_lower) * 0.6
    ]

    Enum.max(scores)
  end

  defp word_similarity(search_words, target_string) do
    target_words = extract_words(target_string)

    if MapSet.size(search_words) == 0 or MapSet.size(target_words) == 0 do
      0.0
    else
      intersection = MapSet.intersection(search_words, target_words) |> MapSet.size()
      union = MapSet.union(search_words, target_words) |> MapSet.size()
      intersection / union
    end
  end

  defp extract_words(string) do
    string
    |> String.downcase()
    |> String.split(~r/[\s\-_\/]+/)
    |> Enum.reject(&(&1 in ~w(the a an and or for with stock)))
    |> Enum.reject(&(String.length(&1) < 2))
    |> MapSet.new()
  end

  defp normalize(name) do
    name
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end

  defp resource_for_type(:cylinder), do: Cylinder
  defp resource_for_type(:carburetor), do: Carburetor
  defp resource_for_type(:exhaust), do: Exhaust
  defp resource_for_type(:ignition), do: Ignition
  defp resource_for_type(:clutch), do: Clutch
  defp resource_for_type(:crank), do: Crank
  defp resource_for_type(:engine), do: Engine
  defp resource_for_type(_), do: nil

  @doc """
  Checks if a part type was successfully matched.
  """
  def matched?(matched_parts, part_type) do
    case Map.get(matched_parts, part_type) do
      {:ok, _} -> true
      _ -> false
    end
  end

  @doc """
  Returns a list of unmatched parts with their original names.
  Used for appending to the build description.
  """
  def unmatched_parts(matched_parts, original_parts) do
    matched_parts
    |> Enum.filter(fn {_type, result} -> result == {:error, :not_found} end)
    |> Enum.map(fn {type, _} ->
      part_info = Map.get(original_parts, type)
      {type, extract_part_name(part_info)}
    end)
    |> Enum.reject(fn {_type, name} -> is_nil(name) end)
  end

  @doc """
  Formats unmatched parts as text to append to description.
  """
  def format_unmatched_for_description(matched_parts, original_parts) do
    unmatched = unmatched_parts(matched_parts, original_parts)

    if Enum.empty?(unmatched) do
      nil
    else
      parts_text =
        unmatched
        |> Enum.map(fn {type, name} ->
          "#{humanize(type)}: #{name}"
        end)
        |> Enum.join(", ")

      "\n\n**Imported Parts (from '77 Garage):** #{parts_text}"
    end
  end

  defp humanize(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
