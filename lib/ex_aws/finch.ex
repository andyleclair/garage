defmodule ExAws.Finch do
  @behaviour ExAws.Request.HttpClient

  require Logger

  def request(method, url, body, headers, _http_opts) do
    case Finch.build(method, url, headers, body)
         |> Finch.request(Garage.Finch) do
      {:ok, resp} ->
        {:ok, %{status_code: resp.status, body: resp.body, headers: resp.headers}}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end
end
