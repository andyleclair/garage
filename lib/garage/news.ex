defmodule Garage.News do
  @moduledoc """
  Context module for loading and parsing news posts from markdown files.

  News posts are stored as markdown files in priv/news/ with the following format:
  - Filename: YYYY-MM-DD-slug.md (e.g., 2024-01-15-welcome-to-moped-club.md)
  - Front matter: YAML-style metadata at the top of the file between --- delimiters
  - Content: Markdown content after the front matter

  Example file:
  ```
  ---
  title: Welcome to Moped Club
  author: Admin
  ---

  Your markdown content here...
  ```
  """

  defmodule Post do
    @moduledoc """
    Struct representing a news post.
    """
    defstruct [:slug, :title, :date, :author, :body, :excerpt]

    @type t :: %__MODULE__{
            slug: String.t(),
            title: String.t(),
            date: Date.t(),
            author: String.t(),
            body: String.t(),
            excerpt: String.t()
          }
  end

  @news_dir "priv/news"

  @doc """
  Returns the directory where news posts are stored.
  """
  def news_dir do
    Application.app_dir(:garage, @news_dir)
  end

  @doc """
  Lists all news posts, sorted by date descending (newest first).
  """
  def list_posts do
    news_dir()
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".md"))
    |> Enum.map(&load_post/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(& &1.date, {:desc, Date})
  end

  @doc """
  Returns the latest n posts.
  """
  def latest_posts(count \\ 3) do
    list_posts()
    |> Enum.take(count)
  end

  @doc """
  Gets a single post by its slug.
  """
  def get_post(slug) do
    filename = find_file_by_slug(slug)

    if filename do
      load_post(filename)
    else
      nil
    end
  end

  @doc """
  Gets a single post by its slug, raises if not found.
  """
  def get_post!(slug) do
    case get_post(slug) do
      nil -> raise "Post not found: #{slug}"
      post -> post
    end
  end

  # Private functions

  defp find_file_by_slug(slug) do
    news_dir()
    |> File.ls!()
    |> Enum.find(fn filename ->
      String.ends_with?(filename, ".md") && extract_slug(filename) == slug
    end)
  end

  defp load_post(filename) do
    path = Path.join(news_dir(), filename)

    with {:ok, content} <- File.read(path),
         {:ok, post} <- parse_post(filename, content) do
      post
    else
      _ -> nil
    end
  end

  defp parse_post(filename, content) do
    {:ok, metadata, body} = parse_front_matter(content)
    date = extract_date(filename)
    slug = extract_slug(filename)

    {:ok, html} =
      MDEx.to_html(body, extension: [autolink: true, strikethrough: true, table: true])

    excerpt = generate_excerpt(body)

    {:ok,
     %Post{
       slug: slug,
       title: Map.get(metadata, "title", "Untitled"),
       date: date,
       author: Map.get(metadata, "author", "Unknown"),
       body: html,
       excerpt: excerpt
     }}
  end

  defp parse_front_matter(content) do
    case String.split(content, ~r/\n---\n/, parts: 2) do
      ["---" <> yaml_content, body] ->
        metadata = parse_yaml(yaml_content)
        {:ok, metadata, String.trim(body)}

      _ ->
        # No front matter, treat entire content as body
        {:ok, %{}, String.trim(content)}
    end
  end

  defp parse_yaml(yaml_string) do
    yaml_string
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse_yaml_line/1)
    |> Enum.reject(&is_nil/1)
    |> Map.new()
  end

  defp parse_yaml_line(line) do
    case String.split(line, ":", parts: 2) do
      [key, value] -> {String.trim(key), String.trim(value)}
      _ -> nil
    end
  end

  # Extract date from filename like "2024-01-15-slug.md"
  defp extract_date(filename) do
    case Regex.run(~r/^(\d{4}-\d{2}-\d{2})-/, filename) do
      [_, date_str] ->
        case Date.from_iso8601(date_str) do
          {:ok, date} -> date
          _ -> Date.utc_today()
        end

      _ ->
        Date.utc_today()
    end
  end

  # Extract slug from filename like "2024-01-15-my-post-slug.md" -> "my-post-slug"
  defp extract_slug(filename) do
    filename
    |> String.replace(~r/^\d{4}-\d{2}-\d{2}-/, "")
    |> String.replace(~r/\.md$/, "")
  end

  # Generate a plain text excerpt from markdown by parsing it first
  defp generate_excerpt(markdown, max_length \\ 200) do
    # Convert markdown to HTML, then strip HTML tags to get plain text
    {:ok, html} = MDEx.to_html(markdown, extension: [autolink: true, strikethrough: true])

    html
    |> Floki.parse_document!()
    |> Floki.text(sep: " ")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> String.slice(0, max_length)
    |> then(fn text ->
      if String.length(text) >= max_length do
        text <> "..."
      else
        text
      end
    end)
  end
end
