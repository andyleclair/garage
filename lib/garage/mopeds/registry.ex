defmodule Garage.Mopeds.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Garage.Mopeds.Carburetor
    entry Garage.Mopeds.Clutch
    entry Garage.Mopeds.Crank
    entry Garage.Mopeds.Cylinder
    entry Garage.Mopeds.Engine
    entry Garage.Mopeds.Exhaust
    entry Garage.Mopeds.Forks
    entry Garage.Mopeds.Ignition
    entry Garage.Mopeds.Make
    entry Garage.Mopeds.Model
    entry Garage.Mopeds.Pulley
    entry Garage.Mopeds.Variator
    entry Garage.Mopeds.Wheels
  end
end
