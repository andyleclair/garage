defmodule Garage.Builds do
  use Ash.Api

  resources do
    registry Garage.Builds.Registry
  end
end
