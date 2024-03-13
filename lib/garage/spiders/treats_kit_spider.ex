# defmodule TreatsKitSpider do
#  use Crawly.Spider
#
#  @impl Crawly.Spider
#  def base_url(), do: "https://www.treatland.tv"
#
#  @impl Crawly.Spider
#  def init() do
#    [start_urls: ["https://www.treatland.tv/Speed-kits-s/100.htm"]]
#  end
#
#  @impl Crawly.Spider
#  @doc """
#     Extract items and requests to follow from the given response
#  """
#  def parse_item(response) do
#    # Extract item field from the response here. Usually it's done this way:
#    {:ok, document} = Floki.parse_document(response.body)
#
#    extracted_items =
#      document
#      |> Floki.find("a.productnamecolor")
#      |> Enum.map(fn x ->
#        name =
#          Floki.attribute(x, "title")
#          |> List.first()
#          |> String.split(",")
#          |> List.first()
#          |> String.replace("carburetor", "")
#
#        displacement =
#          Regex.run(~r/\d+cc/, name)
#          |> case do
#            nil -> nil
#            [size] -> size
#          end
#
#        %{
#          name: name,
#          displacement: displacement
#        }
#      end)
#
#    # Extract requests to follow from the response. Don't forget that you should
#    # supply request objects here. Usually it's done via
#    #
#    # Don't forget that you need absolute urls
#
#    next_requests =
#      document
#      |> Floki.find("input.next_page_img")
#      |> Floki.attribute("onclick")
#      |> Enum.uniq()
#      |> List.first()
#      |> case do
#        nil -> nil
#        str -> Regex.run(~r/(\d)/, str, capture: :first)
#      end
#      |> case do
#        nil ->
#          []
#
#        [num] ->
#          "https://www.treatland.tv/Speed-kits-s/100.htm?searching=Y&sort=5&cat=100&show=50&page=#{num}"
#      end
#      |> List.wrap()
#      |> Crawly.Utils.requests_from_urls()
#
#    %Crawly.ParsedItem{items: extracted_items, requests: next_requests}
#  end
# end
