defmodule GarageWeb.PyroOverrides do
  @moduledoc false

  use Pyro.Overrides

  override Core, :button do
    set :class, "p-2 bg-aoi rounded-lg text-white uppercase"
  end
end
