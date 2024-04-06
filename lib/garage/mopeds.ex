defmodule Garage.Mopeds do
  use Ash.Domain

  resources do
    resource Garage.Mopeds.Carburetor
    resource Garage.Mopeds.Clutch
    resource Garage.Mopeds.Crank
    resource Garage.Mopeds.Cylinder
    resource Garage.Mopeds.Engine
    resource Garage.Mopeds.Exhaust
    resource Garage.Mopeds.Ignition
    resource Garage.Mopeds.Manufacturer
    resource Garage.Mopeds.Model
    resource Garage.Mopeds.Pulley
    resource Garage.Mopeds.Variator
  end
end
