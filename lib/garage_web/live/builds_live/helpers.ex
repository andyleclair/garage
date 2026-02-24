defmodule GarageWeb.BuildsLive.Helpers do
  @moduledoc ~S"""
  Shared helpers for builds
  """
  alias AshPhoenix.Form

  def form_manufacturer_id(form) do
    case Form.value(form, :manufacturer_id) do
      "" ->
        nil

      nil ->
        nil

      manufacturer_id ->
        manufacturer_id
    end
  end

  def year_options() do
    current_year = Date.utc_today().year
    current_year..1900//-1 |> Enum.to_list()
  end
end
