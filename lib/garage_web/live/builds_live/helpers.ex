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
    2023..1900 |> Enum.to_list()
  end
end
