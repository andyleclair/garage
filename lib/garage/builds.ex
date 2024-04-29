defmodule Garage.Builds do
  use Ash.Domain

  resources do
    resource Garage.Builds.Build
    resource Garage.Builds.CarbTuning
    resource Garage.Builds.CylinderTuning
    resource Garage.Builds.ClutchTuning
    resource Garage.Builds.IgnitionTuning
    resource Garage.Builds.VariatorTuning
    resource Garage.Builds.Like
    resource Garage.Builds.Follow
    resource Garage.Builds.Comment
  end
end
