defmodule Garage.Mopeds do
  use Ash.Api

  resources do
    registry Garage.Mopeds.Registry
  end
end
