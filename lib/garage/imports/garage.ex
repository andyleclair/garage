defmodule Garage.Imports.Garage do
  @moduledoc """
  Imports builds from 1977 Mopeds Garage
  https://garage.1977mopeds.com
  """

  require Logger

  @base_url "https://garage.1977mopeds.com"

  @doc """
  Validates that a URL is a valid '77 Garage build URL.
  """
  def valid_url?(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: host, path: path} when is_binary(path) ->
        host in ["garage.1977mopeds.com", "www.garage.1977mopeds.com"] and
          String.starts_with?(path, "/build/")

      _ ->
        false
    end
  end

  def valid_url?(_), do: false

  @doc """
  Fetches and parses a build from '77 Garage.

  Returns `{:ok, parsed_build}` on success, or `{:error, reason}` on failure.

  ## Error reasons
  - `:invalid_url` - URL is not a valid '77 Garage build URL
  - `:not_found` - Build was not found (404)
  - `:service_unavailable` - '77 Garage is down or unreachable
  - `{:http_error, status}` - Other HTTP error
  - `{:parse_error, reason}` - Failed to parse the HTML
  """
  def get_build(url) do
    if valid_url?(url) do
      fetch_and_parse(url)
    else
      {:error, :invalid_url}
    end
  end

  defp fetch_and_parse(url) do
    request = Finch.build(:get, url, [{"User-Agent", "MopedClub/1.0"}])

    case Finch.request(request, Garage.Finch, receive_timeout: 15_000) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        parse_build(body)

      {:ok, %Finch.Response{status: 404}} ->
        {:error, :not_found}

      {:ok, %Finch.Response{status: status}} when status in 500..599 ->
        {:error, :service_unavailable}

      {:ok, %Finch.Response{status: status}} ->
        {:error, {:http_error, status}}

      {:error, %Mint.TransportError{reason: reason}} ->
        Logger.warning("Failed to connect to '77 Garage: #{inspect(reason)}")
        {:error, :service_unavailable}

      {:error, reason} ->
        Logger.warning("Failed to fetch build from '77 Garage: #{inspect(reason)}")
        {:error, :service_unavailable}
    end
  end

  @doc """
  Parses the HTML body of a '77 Garage build page.

  Returns a map with:
  - `:name` - Build name
  - `:description` - Build description
  - `:year` - Year as integer
  - `:manufacturer_name` - Manufacturer name (e.g., "Peugeot")
  - `:model_name` - Model name (e.g., "103SP")
  - `:image_urls` - List of full-resolution image URLs
  - `:parts` - Map of part categories to part info
  """
  def parse_build(html) do
    case Floki.parse_document(html) do
      {:ok, document} ->
        {:ok, extract_build_data(document)}

      {:error, reason} ->
        {:error, {:parse_error, reason}}
    end
  end

  defp extract_build_data(document) do
    %{
      name: extract_name(document),
      description: extract_description(document),
      year: extract_year(document),
      manufacturer_name: extract_manufacturer(document),
      model_name: extract_model(document),
      image_urls: extract_images(document),
      parts: extract_parts(document)
    }
  end

  defp extract_name(document) do
    document
    |> Floki.find("section.g-module h1")
    |> Floki.text()
    |> String.trim()
  end

  defp extract_description(document) do
    document
    |> Floki.find("section.build-description p")
    |> extract_html_content()
  end

  # Extract content from HTML elements and convert to Trix-compatible HTML
  defp extract_html_content([]), do: nil

  defp extract_html_content(elements) do
    elements
    |> Enum.map(&element_to_html/1)
    |> Enum.join("")
    |> String.trim()
    |> case do
      "" -> nil
      html -> html
    end
  end

  # Convert a Floki element to HTML, preserving structure
  defp element_to_html({tag, _attrs, children}) when tag in ["p", "div"] do
    inner = children |> Enum.map(&element_to_html/1) |> Enum.join("")
    "<div>#{inner}</div>"
  end

  defp element_to_html({tag, _attrs, children}) when tag in ["strong", "b"] do
    inner = children |> Enum.map(&element_to_html/1) |> Enum.join("")
    "<strong>#{inner}</strong>"
  end

  defp element_to_html({tag, _attrs, children}) when tag in ["em", "i"] do
    inner = children |> Enum.map(&element_to_html/1) |> Enum.join("")
    "<em>#{inner}</em>"
  end

  defp element_to_html({"br", _attrs, _children}), do: "<br>"

  defp element_to_html({"a", attrs, children}) do
    href =
      Enum.find_value(attrs, "", fn
        {"href", val} -> val
        _ -> nil
      end)

    inner = children |> Enum.map(&element_to_html/1) |> Enum.join("")
    "<a href=\"#{href}\">#{inner}</a>"
  end

  defp element_to_html({_tag, _attrs, children}) do
    # For other tags, just extract the content
    children |> Enum.map(&element_to_html/1) |> Enum.join("")
  end

  # Plain text - convert newlines to <br> tags and escape HTML
  defp element_to_html(text) when is_binary(text) do
    text
    # Normalize whitespace (tabs and multiple spaces to single space)
    |> String.replace(~r/[\t ]+/, " ")
    |> String.trim()
    |> html_escape()
    |> String.replace(~r/\r?\n/, "<br>")
  end

  defp element_to_html(_), do: ""

  defp html_escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end

  defp extract_year(document) do
    # Year is in the MOPED section, format: "MOPED\n1978 Peugeot 103SP"
    # We need to find a 4-digit year anywhere in the text
    moped_text = find_category_text(document, "MOPED")

    case Regex.run(~r/(\d{4})/, moped_text) do
      [_, year_str] -> String.to_integer(year_str)
      _ -> nil
    end
  end

  defp extract_manufacturer(document) do
    # The manufacturer is in the anchor link text: " Peugeot 103SP"
    # Extract first word from the link
    document
    |> Floki.find(".g-build-detail-category")
    |> Enum.find(fn el -> category_matches?(el, "MOPED") end)
    |> case do
      nil ->
        nil

      category_el ->
        category_el
        |> Floki.find("a")
        |> Floki.text()
        |> String.trim()
        |> extract_manufacturer_from_text()
    end
  end

  defp extract_manufacturer_from_text(text) do
    # Text is like "Peugeot 103SP" - extract manufacturer (first word)
    case String.split(text, " ", parts: 2) do
      [manufacturer, _model] -> manufacturer
      [manufacturer] -> manufacturer
      _ -> nil
    end
  end

  defp extract_model(document) do
    # Try to get model from the link in MOPED section
    document
    |> Floki.find(".g-build-detail-category")
    |> Enum.find(fn el -> category_matches?(el, "MOPED") end)
    |> case do
      nil ->
        nil

      category_el ->
        category_el
        |> Floki.find("a")
        |> Floki.text()
        |> String.trim()
        |> extract_model_from_text()
    end
  end

  defp extract_model_from_text(text) do
    # Text is like "Peugeot 103SP" - extract model part (everything after first word)
    case String.split(text, " ", parts: 2) do
      [_manufacturer, model] -> model
      _ -> text
    end
  end

  defp extract_images(document) do
    document
    |> Floki.find("ul.slides li img")
    |> Floki.attribute("src")
    |> Enum.map(&to_absolute_url/1)
    |> Enum.uniq()
  end

  defp to_absolute_url(path) when is_binary(path) do
    if String.starts_with?(path, "http") do
      path
    else
      @base_url <> path
    end
  end

  defp extract_parts(document) do
    %{
      engine: find_part_value(document, "engine", "Engine"),
      cylinder: find_part_value(document, "engine", "Cylinder"),
      crank: find_part_value(document, "engine", "Crank"),
      carburetor: extract_carb_tuning(document),
      exhaust: find_part_value(document, "exhaust", "Pipe"),
      ignition: find_part_value(document, "electrical", "Ignition"),
      clutch: find_part_value(document, "transmission", "Clutch")
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp find_category_text(document, category_name) do
    document
    |> Floki.find(".g-build-detail-category")
    |> Enum.find(fn el -> category_matches?(el, category_name) end)
    |> case do
      nil -> ""
      el -> Floki.text(el) |> String.trim()
    end
  end

  defp category_matches?(element, category_name) do
    element
    |> Floki.find("h5")
    |> Floki.text()
    |> String.trim()
    |> String.upcase()
    |> Kernel.==(String.upcase(category_name))
  end

  defp find_part_value(document, category_name, part_label) do
    document
    |> Floki.find(".g-build-detail-category")
    |> Enum.find(fn el -> category_matches?(el, category_name) end)
    |> case do
      nil ->
        nil

      category_el ->
        category_el
        |> Floki.find("li")
        |> Enum.find(fn li ->
          li
          |> Floki.find(".g-build-attr")
          |> Floki.text()
          |> String.trim()
          |> String.trim_trailing(":")
          |> String.downcase()
          |> Kernel.==(String.downcase(part_label))
        end)
        |> case do
          nil -> nil
          li -> li |> Floki.find(".g-build-attr-val") |> Floki.text() |> String.trim()
        end
    end
  end

  defp extract_carb_tuning(document) do
    carb_name = find_part_value(document, "carburetion", "Carb")

    if carb_name do
      main_jet = find_simple_value(document, "carburetion", "Main")
      idle_jet = find_simple_value(document, "carburetion", "Idle")

      %{
        name: carb_name,
        main_jet: parse_jet(main_jet),
        idle_jet: parse_jet(idle_jet)
      }
    else
      nil
    end
  end

  defp find_simple_value(document, category_name, label) do
    document
    |> Floki.find(".g-build-detail-category")
    |> Enum.find(fn el -> category_matches?(el, category_name) end)
    |> case do
      nil ->
        nil

      category_el ->
        category_el
        |> Floki.find("li")
        |> Enum.find(fn li ->
          li
          |> Floki.find(".g-build-attr")
          |> Floki.text()
          |> String.trim()
          |> String.trim_trailing(":")
          |> String.downcase()
          |> Kernel.==(String.downcase(label))
        end)
        |> case do
          nil ->
            nil

          li ->
            # For simple values, the value is direct text after the label span
            li
            |> Floki.text()
            |> String.replace(~r/^.*?:\s*/, "")
            |> String.trim()
        end
    end
  end

  defp parse_jet(nil), do: nil

  defp parse_jet(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> nil
    end
  end

  @doc """
  Formats an error reason into a user-friendly message.
  """
  def format_error(:invalid_url) do
    "Please enter a valid '77 Garage URL (e.g., https://garage.1977mopeds.com/build/...)"
  end

  def format_error(:not_found) do
    "Build not found. Please check the URL and try again."
  end

  def format_error(:service_unavailable) do
    "'77 Garage appears to be down or unreachable. Please try again later."
  end

  def format_error({:http_error, status}) do
    "'77 Garage returned an error (HTTP #{status}). Please try again later."
  end

  def format_error({:parse_error, _}) do
    "Failed to parse the build page. The page format may have changed."
  end

  def format_error(_) do
    "An unexpected error occurred. Please try again."
  end
end
