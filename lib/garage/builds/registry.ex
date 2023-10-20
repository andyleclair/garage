defmodule Garage.Builds.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Garage.Builds.Build
    entry Garage.Builds.Like
  end
end
