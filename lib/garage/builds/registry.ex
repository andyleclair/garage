defmodule Garage.Builds.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Garage.Builds.Build
    entry Garage.Builds.Like
    entry Garage.Builds.Comment
  end
end
