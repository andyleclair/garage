defmodule Garage.Mopeds.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Garage.Mopeds.Make
    entry Garage.Mopeds.Model
  end
end
